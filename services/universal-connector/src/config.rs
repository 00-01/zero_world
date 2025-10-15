// Configuration management

use serde::Deserialize;
use anyhow::Result;

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    /// Redis connection URL for L2 cache
    pub redis_url: String,
    
    /// PostgreSQL connection URL for metadata
    pub database_url: String,
    
    /// API keys for external services
    pub api_keys: ApiKeys,
    
    /// Cache settings
    pub cache: CacheConfig,
    
    /// Performance settings
    pub performance: PerformanceConfig,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ApiKeys {
    pub google_api_key: Option<String>,
    pub openweather_api_key: Option<String>,
    pub news_api_key: Option<String>,
    pub bing_api_key: Option<String>,
    // Add more API keys as needed
}

#[derive(Debug, Clone, Deserialize)]
pub struct CacheConfig {
    /// L1 (in-memory) cache size in MB
    pub l1_size_mb: usize,
    
    /// L1 cache TTL in seconds
    pub l1_ttl_secs: u64,
    
    /// L2 (Redis) cache TTL in seconds
    pub l2_ttl_secs: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct PerformanceConfig {
    /// Maximum parallel requests
    pub max_parallel_requests: usize,
    
    /// Global timeout in milliseconds
    pub global_timeout_ms: u64,
    
    /// Worker threads
    pub worker_threads: usize,
}

impl Config {
    pub fn from_env() -> Result<Self> {
        dotenv::dotenv().ok();
        
        Ok(Config {
            redis_url: std::env::var("REDIS_URL")
                .unwrap_or_else(|_| "redis://localhost:6379".to_string()),
            
            database_url: std::env::var("DATABASE_URL")
                .unwrap_or_else(|_| "postgres://localhost/zero_world".to_string()),
            
            api_keys: ApiKeys {
                google_api_key: std::env::var("GOOGLE_API_KEY").ok(),
                openweather_api_key: std::env::var("OPENWEATHER_API_KEY").ok(),
                news_api_key: std::env::var("NEWS_API_KEY").ok(),
                bing_api_key: std::env::var("BING_API_KEY").ok(),
            },
            
            cache: CacheConfig {
                l1_size_mb: std::env::var("CACHE_L1_SIZE_MB")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(256),
                
                l1_ttl_secs: std::env::var("CACHE_L1_TTL_SECS")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(300), // 5 minutes
                
                l2_ttl_secs: std::env::var("CACHE_L2_TTL_SECS")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(3600), // 1 hour
            },
            
            performance: PerformanceConfig {
                max_parallel_requests: std::env::var("MAX_PARALLEL_REQUESTS")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(50),
                
                global_timeout_ms: std::env::var("GLOBAL_TIMEOUT_MS")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(1000), // 1 second
                
                worker_threads: std::env::var("WORKER_THREADS")
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(num_cpus::get()),
            },
        })
    }
}
