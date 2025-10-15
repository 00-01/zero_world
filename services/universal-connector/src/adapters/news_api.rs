// News API Adapter

use crate::models::{DataSourceAdapter, Query, SourceResult, AdapterError};
use async_trait::async_trait;

pub struct NewsApiAdapter;

impl NewsApiAdapter {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self {})
    }
}

#[async_trait]
impl DataSourceAdapter for NewsApiAdapter {
    fn name(&self) -> &str {
        "news_api"
    }
    
    async fn fetch(&self, _query: &Query) -> Result<SourceResult, AdapterError> {
        // TODO: Implement NewsAPI.org
        Ok(SourceResult {
            source: self.name().to_string(),
            success: false,
            latency_ms: 0,
            data: None,
            error: Some("Not implemented yet".to_string()),
            confidence: 0.0,
            relevance: 0.0,
        })
    }
    
    fn can_handle(&self, query: &Query) -> bool {
        query.intent == "news" || query.intent == "current_events"
    }
}
