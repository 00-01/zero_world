// Two-tier caching system
// L1: In-memory (Moka) - Ultra fast, <1ms access
// L2: Redis - Distributed, shared across instances

use crate::config::Config;
use crate::models::QueryResponse;
use moka::future::Cache as MokaCache;
use redis::AsyncCommands;
use anyhow::Result;
use tokio::time::Duration;
use tracing::{debug, warn};

pub struct Cache {
    /// L1: In-memory cache (per instance)
    l1: MokaCache<String, QueryResponse>,
    
    /// L2: Redis cache (shared across instances)
    l2: redis::aio::ConnectionManager,
    
    l1_ttl: Duration,
    l2_ttl: Duration,
}

impl Cache {
    pub async fn new(config: &Config) -> Result<Self> {
        debug!("🗄️  Initializing two-tier cache system");
        
        // Initialize L1 cache (in-memory)
        let l1 = MokaCache::builder()
            .max_capacity(config.cache.l1_size_mb as u64 * 1024 * 1024) // Convert MB to bytes
            .time_to_live(Duration::from_secs(config.cache.l1_ttl_secs))
            .build();
        
        // Initialize L2 cache (Redis)
        let client = redis::Client::open(config.redis_url.as_str())?;
        let l2 = redis::aio::ConnectionManager::new(client).await?;
        
        debug!("  ✓ L1 cache: {} MB, TTL: {}s", 
            config.cache.l1_size_mb, 
            config.cache.l1_ttl_secs
        );
        debug!("  ✓ L2 cache: Redis, TTL: {}s", config.cache.l2_ttl_secs);
        
        Ok(Self {
            l1,
            l2,
            l1_ttl: Duration::from_secs(config.cache.l1_ttl_secs),
            l2_ttl: Duration::from_secs(config.cache.l2_ttl_secs),
        })
    }
    
    /// Get from cache (L1 first, then L2)
    pub async fn get(&self, key: &str) -> Result<Option<QueryResponse>> {
        // Try L1 first (in-memory, ultra fast)
        if let Some(value) = self.l1.get(key).await {
            debug!("💨 L1 cache hit: {}", key);
            return Ok(Some(value));
        }
        
        // Try L2 (Redis, slower but shared)
        let cache_key = format!("query:{}", key);
        let mut conn = self.l2.clone();
        
        match conn.get::<_, Option<String>>(&cache_key).await {
            Ok(Some(json)) => {
                debug!("💨 L2 cache hit: {}", key);
                if let Ok(value) = serde_json::from_str::<QueryResponse>(&json) {
                    // Store in L1 for next time
                    self.l1.insert(key.to_string(), value.clone()).await;
                    return Ok(Some(value));
                }
            }
            Ok(None) => {
                debug!("❌ Cache miss: {}", key);
            }
            Err(e) => {
                warn!("⚠️  L2 cache error: {}", e);
            }
        }
        
        Ok(None)
    }
    
    /// Set in both L1 and L2 caches
    pub async fn set(&self, key: &str, value: &QueryResponse, ttl: Duration) -> Result<()> {
        // Set in L1 (in-memory)
        self.l1.insert(key.to_string(), value.clone()).await;
        
        // Set in L2 (Redis)
        let cache_key = format!("query:{}", key);
        let json = serde_json::to_string(value)?;
        let mut conn = self.l2.clone();
        
        match conn.set_ex::<_, _, ()>(&cache_key, json, ttl.as_secs() as u64).await {
            Ok(_) => {
                debug!("✓ Cached in L1 + L2: {}", key);
                Ok(())
            }
            Err(e) => {
                warn!("⚠️  Failed to cache in L2: {}", e);
                // L1 is still cached, so this is not critical
                Ok(())
            }
        }
    }
    
    /// Invalidate cache entry
    pub async fn invalidate(&self, key: &str) -> Result<()> {
        // Remove from L1
        self.l1.invalidate(key).await;
        
        // Remove from L2
        let cache_key = format!("query:{}", key);
        let mut conn = self.l2.clone();
        conn.del::<_, ()>(&cache_key).await?;
        
        debug!("🗑️  Invalidated cache: {}", key);
        Ok(())
    }
}
