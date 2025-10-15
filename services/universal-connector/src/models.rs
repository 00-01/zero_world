// Data models for Universal Connector

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Query from Intent Recognition service
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Query {
    /// The original user query text
    pub text: String,
    
    /// Recognized intent (e.g., "weather", "search", "price_comparison")
    pub intent: String,
    
    /// Extracted entities
    pub entities: HashMap<String, String>,
    
    /// Suggested data sources to query
    pub sources: Vec<String>,
    
    /// User context
    pub context: Option<UserContext>,
    
    /// Maximum response time in milliseconds
    pub timeout_ms: Option<u64>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct UserContext {
    pub user_id: String,
    pub location: Option<Location>,
    pub timezone: Option<String>,
    pub preferences: HashMap<String, String>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Location {
    pub latitude: f64,
    pub longitude: f64,
    pub city: Option<String>,
    pub country: Option<String>,
}

/// Response to send to Synthesis Engine
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct QueryResponse {
    /// Query ID for tracking
    pub query_id: String,
    
    /// Results from each source
    pub results: Vec<SourceResult>,
    
    /// Total time taken in milliseconds
    pub latency_ms: u64,
    
    /// Number of sources queried
    pub sources_queried: usize,
    
    /// Number of sources that succeeded
    pub sources_succeeded: usize,
    
    /// Cache hit or miss
    pub cache_hit: bool,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct SourceResult {
    /// Data source name
    pub source: String,
    
    /// Success status
    pub success: bool,
    
    /// Response time in milliseconds
    pub latency_ms: u64,
    
    /// Retrieved data (JSON format)
    pub data: Option<serde_json::Value>,
    
    /// Error message if failed
    pub error: Option<String>,
    
    /// Confidence score (0.0 to 1.0)
    pub confidence: f32,
    
    /// Relevance score (0.0 to 1.0)
    pub relevance: f32,
}

/// Data source adapter trait
/// Each data source (Google, Wikipedia, Weather API, etc.) implements this
#[async_trait::async_trait]
pub trait DataSourceAdapter: Send + Sync {
    /// Unique identifier for this data source
    fn name(&self) -> &str;
    
    /// Fetch data from this source
    async fn fetch(&self, query: &Query) -> Result<SourceResult, AdapterError>;
    
    /// Check if this adapter can handle the query
    fn can_handle(&self, query: &Query) -> bool;
    
    /// Get rate limit (requests per second)
    fn rate_limit(&self) -> u32 {
        100 // Default: 100 req/s
    }
    
    /// Get timeout in milliseconds
    fn timeout_ms(&self) -> u64 {
        500 // Default: 500ms
    }
}

/// Adapter-specific errors
#[derive(Debug, thiserror::Error)]
pub enum AdapterError {
    #[error("Network error: {0}")]
    Network(String),
    
    #[error("API error: {0}")]
    Api(String),
    
    #[error("Timeout after {0}ms")]
    Timeout(u64),
    
    #[error("Rate limit exceeded")]
    RateLimit,
    
    #[error("Authentication failed")]
    Auth,
    
    #[error("Parse error: {0}")]
    Parse(String),
    
    #[error("Unknown error: {0}")]
    Unknown(String),
}

impl From<AdapterError> for SourceResult {
    fn from(error: AdapterError) -> Self {
        SourceResult {
            source: "unknown".to_string(),
            success: false,
            latency_ms: 0,
            data: None,
            error: Some(error.to_string()),
            confidence: 0.0,
            relevance: 0.0,
        }
    }
}
