// Weather API Adapter

use crate::models::{DataSourceAdapter, Query, SourceResult, AdapterError};
use async_trait::async_trait;

pub struct WeatherApiAdapter;

impl WeatherApiAdapter {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self {})
    }
}

#[async_trait]
impl DataSourceAdapter for WeatherApiAdapter {
    fn name(&self) -> &str {
        "weather_api"
    }
    
    async fn fetch(&self, _query: &Query) -> Result<SourceResult, AdapterError> {
        // TODO: Implement WeatherAPI.com
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
        query.intent == "weather"
    }
}

pub struct OpenWeatherAdapter;

impl OpenWeatherAdapter {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self {})
    }
}

#[async_trait]
impl DataSourceAdapter for OpenWeatherAdapter {
    fn name(&self) -> &str {
        "openweather"
    }
    
    async fn fetch(&self, _query: &Query) -> Result<SourceResult, AdapterError> {
        // TODO: Implement OpenWeatherMap API
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
        query.intent == "weather"
    }
}
