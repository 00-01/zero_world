// Universal Connector - The Lungs of Zero World
//
// Philosophy: This service "breathes in" data from 1000+ sources and "exhales"
// synthesized results. It's the critical path between user queries and universal
// data access - making Zero World feel like air.
//
// Performance Requirements:
// - <400ms P95 latency for parallel multi-source fetching
// - 10K queries/second per instance
// - 95%+ cache hit rate
// - Graceful degradation (return partial results if some sources fail)
//
// Architecture:
// - Adapter pattern for each data source (1000+ adapters)
// - Parallel fetching with timeout controls
// - Two-tier caching (L1: in-memory, L2: Redis)
// - Circuit breaker for failing sources
// - Rate limiting per source

use axum::{
    routing::{get, post},
    Router, Json,
    extract::State,
    http::StatusCode,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::time::Duration;
use tracing::{info, warn, error};
use anyhow::Result;

mod adapters;
mod cache;
mod config;
mod orchestrator;
mod models;

use crate::config::Config;
use crate::orchestrator::Orchestrator;
use crate::models::{Query, QueryResponse};

#[derive(Clone)]
struct AppState {
    orchestrator: Arc<Orchestrator>,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter("universal_connector=debug,tower_http=debug")
        .init();

    info!("🌬️  Universal Connector - The Lungs of Zero World");
    info!("Starting up...");

    // Load configuration
    let config = Config::from_env()?;
    
    // Initialize orchestrator
    let orchestrator = Arc::new(Orchestrator::new(config).await?);
    
    let app_state = AppState { orchestrator };

    // Build application routes
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/query", post(handle_query))
        .route("/sources", get(list_sources))
        .route("/metrics", get(metrics))
        .with_state(app_state);

    // Start server
    let addr = "0.0.0.0:8080";
    info!("🚀 Listening on {}", addr);
    
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}

/// Health check endpoint
async fn health_check() -> &'static str {
    "💨 Breathing normally"
}

/// Main query endpoint - This is where the magic happens
/// 
/// Process:
/// 1. Receive query intent from Intent Recognition service
/// 2. Select relevant data sources (10-50 sources typically)
/// 3. Fetch from all sources in parallel (with timeouts)
/// 4. Deduplicate and cache results
/// 5. Return to Synthesis Engine
async fn handle_query(
    State(state): State<AppState>,
    Json(query): Json<Query>,
) -> Result<Json<QueryResponse>, StatusCode> {
    info!("🔍 Processing query: {:?}", query.text);
    
    let start = std::time::Instant::now();
    
    // Orchestrate parallel fetching from multiple sources
    match state.orchestrator.fetch_from_sources(&query).await {
        Ok(response) => {
            let elapsed = start.elapsed();
            info!("✅ Query completed in {:?}", elapsed);
            
            // Track metrics
            if elapsed > Duration::from_millis(1000) {
                warn!("⚠️  Slow query: {:?}", elapsed);
            }
            
            Ok(Json(response))
        }
        Err(e) => {
            error!("❌ Query failed: {}", e);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

/// List available data sources
async fn list_sources(
    State(state): State<AppState>,
) -> Json<Vec<String>> {
    Json(state.orchestrator.list_sources())
}

/// Prometheus metrics endpoint
async fn metrics() -> String {
    // TODO: Implement Prometheus metrics
    "# Metrics coming soon".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_health_check() {
        assert_eq!(health_check().await, "💨 Breathing normally");
    }
}
