// Orchestrator - Coordinates parallel fetching from multiple data sources
//
// This is the "breathing" mechanism:
// - Inhale: Fan out queries to 10-50 sources in parallel
// - Process: Each source fetches independently with timeout
// - Exhale: Collect all results and return

use crate::config::Config;
use crate::models::{Query, QueryResponse, SourceResult, DataSourceAdapter};
use crate::cache::Cache;
use crate::adapters::*;

use std::sync::Arc;
use std::time::Instant;
use tokio::time::{timeout, Duration};
use futures::future::join_all;
use tracing::{info, warn, debug};
use uuid::Uuid;

pub struct Orchestrator {
    adapters: Vec<Arc<dyn DataSourceAdapter>>,
    cache: Arc<Cache>,
    config: Config,
}

impl Orchestrator {
    pub async fn new(config: Config) -> anyhow::Result<Self> {
        info!("🔧 Initializing Universal Connector Orchestrator");
        
        // Initialize cache
        let cache = Arc::new(Cache::new(&config).await?);
        
        // Register all data source adapters
        let mut adapters: Vec<Arc<dyn DataSourceAdapter>> = Vec::new();
        
        // Web search adapters
        adapters.push(Arc::new(GoogleSearchAdapter::new()?));
        adapters.push(Arc::new(WikipediaAdapter::new()?));
        
        // Weather adapters
        adapters.push(Arc::new(WeatherApiAdapter::new()?));
        adapters.push(Arc::new(OpenWeatherAdapter::new()?));
        
        // News adapters
        adapters.push(Arc::new(NewsApiAdapter::new()?));
        
        // TODO: Add more adapters
        // - BingSearchAdapter
        // - DuckDuckGoAdapter
        // - RedditAdapter
        // - TwitterAdapter
        // - YouTubeAdapter
        // - GmailAdapter
        // - GoogleDriveAdapter
        // - DropboxAdapter
        // - SlackAdapter
        // - NotionAdapter
        // - JiraAdapter
        // - GitHubAdapter
        // ... (target: 1000+ adapters)
        
        info!("✅ Registered {} data source adapters", adapters.len());
        
        Ok(Self {
            adapters,
            cache,
            config,
        })
    }
    
    /// Fetch data from multiple sources in parallel
    /// This is the core "breathing" function
    pub async fn fetch_from_sources(&self, query: &Query) -> anyhow::Result<QueryResponse> {
        let start = Instant::now();
        let query_id = Uuid::new_v4().to_string();
        
        debug!("🌬️  Inhaling: Starting parallel fetch for {} sources", query.sources.len());
        
        // Check cache first (L1: memory, L2: Redis)
        if let Some(cached) = self.cache.get(&query.text).await? {
            info!("💨 Cache hit! Returning cached result");
            return Ok(cached);
        }
        
        // Select adapters that can handle this query
        let selected_adapters: Vec<_> = self.adapters
            .iter()
            .filter(|adapter| {
                query.sources.is_empty() || query.sources.contains(&adapter.name().to_string())
            })
            .filter(|adapter| adapter.can_handle(query))
            .collect();
        
        info!("📡 Fetching from {} sources in parallel", selected_adapters.len());
        
        // Create fetch tasks for each adapter
        let fetch_tasks = selected_adapters.iter().map(|adapter| {
            let adapter = Arc::clone(adapter);
            let query = query.clone();
            
            async move {
                let adapter_name = adapter.name().to_string();
                let adapter_timeout = Duration::from_millis(adapter.timeout_ms());
                
                debug!("  → Fetching from {}", adapter_name);
                
                // Fetch with timeout
                match timeout(adapter_timeout, adapter.fetch(&query)).await {
                    Ok(Ok(result)) => {
                        debug!("  ✓ {} responded in {}ms", adapter_name, result.latency_ms);
                        result
                    }
                    Ok(Err(e)) => {
                        warn!("  ✗ {} failed: {}", adapter_name, e);
                        SourceResult {
                            source: adapter_name.clone(),
                            success: false,
                            latency_ms: adapter_timeout.as_millis() as u64,
                            data: None,
                            error: Some(e.to_string()),
                            confidence: 0.0,
                            relevance: 0.0,
                        }
                    }
                    Err(_) => {
                        warn!("  ⏱  {} timed out after {}ms", adapter_name, adapter_timeout.as_millis());
                        SourceResult {
                            source: adapter_name.clone(),
                            success: false,
                            latency_ms: adapter_timeout.as_millis() as u64,
                            data: None,
                            error: Some(format!("Timeout after {}ms", adapter_timeout.as_millis())),
                            confidence: 0.0,
                            relevance: 0.0,
                        }
                    }
                }
            }
        });
        
        // Execute all fetches in parallel
        let results = join_all(fetch_tasks).await;
        
        let elapsed = start.elapsed();
        let sources_succeeded = results.iter().filter(|r| r.success).count();
        
        debug!("💨 Exhaling: Collected {} results in {:?}", results.len(), elapsed);
        info!("   Success rate: {}/{}", sources_succeeded, results.len());
        
        let response = QueryResponse {
            query_id,
            results,
            latency_ms: elapsed.as_millis() as u64,
            sources_queried: selected_adapters.len(),
            sources_succeeded,
            cache_hit: false,
        };
        
        // Cache the response (if enough sources succeeded)
        if sources_succeeded >= 1 {
            self.cache.set(&query.text, &response, Duration::from_secs(300)).await?;
        }
        
        Ok(response)
    }
    
    /// List all available data sources
    pub fn list_sources(&self) -> Vec<String> {
        self.adapters
            .iter()
            .map(|a| a.name().to_string())
            .collect()
    }
}
