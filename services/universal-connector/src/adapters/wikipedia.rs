// Wikipedia Adapter - Free knowledge source, no API key required

use crate::models::{DataSourceAdapter, Query, SourceResult, AdapterError};
use async_trait::async_trait;
use reqwest::Client;
use serde_json::Value;
use std::time::Instant;

pub struct WikipediaAdapter {
    client: Client,
    base_url: String,
}

impl WikipediaAdapter {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self {
            client: Client::builder()
                .timeout(std::time::Duration::from_millis(500))
                .build()?,
            base_url: "https://en.wikipedia.org/api/rest_v1".to_string(),
        })
    }
}

#[async_trait]
impl DataSourceAdapter for WikipediaAdapter {
    fn name(&self) -> &str {
        "wikipedia"
    }
    
    async fn fetch(&self, query: &Query) -> Result<SourceResult, AdapterError> {
        let start = Instant::now();
        
        // Extract search term from query
        let search_term = query.entities.get("topic")
            .or_else(|| query.entities.get("subject"))
            .map(|s| s.as_str())
            .unwrap_or(&query.text);
        
        // Search Wikipedia
        let search_url = format!(
            "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch={}",
            urlencoding::encode(search_term)
        );
        
        let response = self.client
            .get(&search_url)
            .send()
            .await
            .map_err(|e| AdapterError::Network(e.to_string()))?;
        
        if !response.status().is_success() {
            return Err(AdapterError::Api(format!("HTTP {}", response.status())));
        }
        
        let json: Value = response
            .json()
            .await
            .map_err(|e| AdapterError::Parse(e.to_string()))?;
        
        // Extract search results
        let search_results = json["query"]["search"]
            .as_array()
            .ok_or_else(|| AdapterError::Parse("No search results".to_string()))?;
        
        if search_results.is_empty() {
            return Ok(SourceResult {
                source: self.name().to_string(),
                success: true,
                latency_ms: start.elapsed().as_millis() as u64,
                data: Some(serde_json::json!({
                    "message": "No Wikipedia articles found",
                    "results": []
                })),
                error: None,
                confidence: 0.0,
                relevance: 0.0,
            });
        }
        
        // Get the first result's summary
        let first_result = &search_results[0];
        let title = first_result["title"]
            .as_str()
            .ok_or_else(|| AdapterError::Parse("No title".to_string()))?;
        
        // Fetch article summary
        let summary_url = format!(
            "{}/page/summary/{}",
            self.base_url,
            urlencoding::encode(title)
        );
        
        let summary_response = self.client
            .get(&summary_url)
            .send()
            .await
            .map_err(|e| AdapterError::Network(e.to_string()))?;
        
        let summary: Value = summary_response
            .json()
            .await
            .map_err(|e| AdapterError::Parse(e.to_string()))?;
        
        let elapsed = start.elapsed().as_millis() as u64;
        
        Ok(SourceResult {
            source: self.name().to_string(),
            success: true,
            latency_ms: elapsed,
            data: Some(serde_json::json!({
                "title": summary["title"],
                "extract": summary["extract"],
                "url": summary["content_urls"]["desktop"]["page"],
                "thumbnail": summary.get("thumbnail"),
                "search_results": search_results.len(),
            })),
            error: None,
            confidence: 0.85, // Wikipedia is generally reliable
            relevance: 0.9,   // High relevance for knowledge queries
        })
    }
    
    fn can_handle(&self, query: &Query) -> bool {
        // Wikipedia is good for knowledge, definitions, facts
        matches!(
            query.intent.as_str(),
            "knowledge" | "definition" | "fact" | "search" | "who" | "what" | "when" | "where"
        )
    }
    
    fn rate_limit(&self) -> u32 {
        200 // Wikipedia allows 200 req/s for non-commercial
    }
    
    fn timeout_ms(&self) -> u64 {
        500
    }
}
