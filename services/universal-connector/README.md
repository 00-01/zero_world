# Universal Connector Service

> **"The Mediation Layer for Humanity"** - Connects 10 billion humans to 1 million services

## 🌬️ Philosophy

The Universal Connector is the **orchestration service** that mediates 100% of digital interactions between humans and services.

This is not just a "data aggregator" - this is the **core of Zero World's total mediation architecture**:

- **Inhale**: Fan out requests to 10-1000 services in parallel
- **Mediate**: Each service adapter handles authentication, rate limiting, protocol translation
- **Exhale**: Return synthesized results + execute actions (book, buy, send, schedule)

**Every digital interaction flows through this service:**
- Want to know something? → Query Google, Wikipedia, Wolfram
- Want to buy something? → Query Amazon, eBay, search, then execute purchase
- Want to go somewhere? → Query Uber, Lyft, flights, then book ride
- Want to talk to someone? → Query Slack, email, SMS, then send message

**This is where the "AI Mediator" vision becomes real.**

## 🎯 Goals

### Phase 1 (Current)
- ✅ Core architecture and orchestration
- ✅ Two-tier caching (L1: in-memory, L2: Redis)
- ✅ Parallel fetching with timeout controls
- ✅ Wikipedia adapter (working)
- 🔄 5 adapters (Google, Weather, News, OpenWeather)
- Target: Basic universal data access

### Phase 2 (Month 1-3)
- 50 data source adapters
- Circuit breaker pattern
- Rate limiting per source
- Prometheus metrics
- Target: 95% cache hit rate, <400ms P95 latency

### Phase 3 (Month 4-6)
- 200 adapters
- Personal data sources (Gmail, Drive, Calendar)
- Enterprise sources (Slack, Notion, Jira, GitHub)
- Smart source selection
- Target: 99% uptime, <300ms P95

### Phase 4-5 (Year 1-2)
- 1000+ adapters
- AI-powered result ranking
- Proactive caching
- Edge deployment
- Target: <100ms P95, handle 1M req/s

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      REST API (Axum)                            │
│  POST /query     - Process a query                             │
│  GET  /sources   - List available sources                      │
│  GET  /health    - Health check                                │
│  GET  /metrics   - Prometheus metrics                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Orchestrator                               │
│  • Selects relevant adapters based on intent                   │
│  • Fans out to 10-50 sources in parallel                       │
│  • Collects results with timeout (500ms per source)            │
│  • Handles partial failures gracefully                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Cache Layer                                │
│  L1: Moka (in-memory)    - <1ms access, 256MB, 5min TTL       │
│  L2: Redis (distributed) - 2-5ms access, unlimited, 1hr TTL   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Adapter Registry                               │
│  Currently: 5 adapters                                          │
│  ├─ Wikipedia         (✅ working)                              │
│  ├─ Google Search     (🔄 stub)                                │
│  ├─ Weather API       (🔄 stub)                                │
│  ├─ OpenWeather       (🔄 stub)                                │
│  └─ News API          (🔄 stub)                                │
│                                                                 │
│  Planned: 50+ adapters (Phase 2)                               │
│  Target: 1000+ adapters (Phase 5)                              │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Usage

### Starting the Service

```bash
# Set environment variables
export REDIS_URL="redis://localhost:6379"
export DATABASE_URL="postgres://localhost/zero_world"
export GOOGLE_API_KEY="your-key"
export OPENWEATHER_API_KEY="your-key"
export NEWS_API_KEY="your-key"

# Run the service
cargo run --release

# Or with Docker
docker build -t universal-connector .
docker run -p 8080:8080 universal-connector
```

### Sending a Query

```bash
# Health check
curl http://localhost:8080/health
# Response: 💨 Breathing normally

# List available sources
curl http://localhost:8080/sources
# Response: ["wikipedia", "google_search", "weather_api", ...]

# Send a query
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{
    "text": "What is artificial intelligence?",
    "intent": "knowledge",
    "entities": {
      "topic": "artificial intelligence"
    },
    "sources": ["wikipedia", "google_search"],
    "timeout_ms": 1000
  }'

# Response:
{
  "query_id": "550e8400-e29b-41d4-a716-446655440000",
  "results": [
    {
      "source": "wikipedia",
      "success": true,
      "latency_ms": 342,
      "data": {
        "title": "Artificial intelligence",
        "extract": "Artificial intelligence (AI) is intelligence demonstrated by machines...",
        "url": "https://en.wikipedia.org/wiki/Artificial_intelligence"
      },
      "confidence": 0.85,
      "relevance": 0.9
    }
  ],
  "latency_ms": 342,
  "sources_queried": 2,
  "sources_succeeded": 1,
  "cache_hit": false
}
```

## 📊 Performance

### Current Performance (Phase 1)
- **Latency**: ~342ms (single source, Wikipedia)
- **Throughput**: Not measured yet
- **Cache Hit Rate**: Not measured yet
- **Availability**: Development only

### Target Performance (Phase 2)
- **P50 Latency**: <200ms
- **P95 Latency**: <400ms
- **P99 Latency**: <1000ms
- **Throughput**: 10K requests/second per instance
- **Cache Hit Rate**: >95%
- **Availability**: 99.9% (3 nines)

### Target Performance (Phase 5)
- **P95 Latency**: <100ms
- **Throughput**: 100K requests/second per instance
- **Cache Hit Rate**: >98%
- **Availability**: 99.999% (5 nines)

## 🔌 Adding New Adapters

Each data source needs an adapter. Here's the pattern:

```rust
// src/adapters/my_source.rs

use crate::models::{DataSourceAdapter, Query, SourceResult, AdapterError};
use async_trait::async_trait;
use reqwest::Client;
use std::time::Instant;

pub struct MySourceAdapter {
    client: Client,
    api_key: Option<String>,
}

impl MySourceAdapter {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self {
            client: Client::builder()
                .timeout(std::time::Duration::from_millis(500))
                .build()?,
            api_key: std::env::var("MY_SOURCE_API_KEY").ok(),
        })
    }
}

#[async_trait]
impl DataSourceAdapter for MySourceAdapter {
    fn name(&self) -> &str {
        "my_source"
    }
    
    async fn fetch(&self, query: &Query) -> Result<SourceResult, AdapterError> {
        let start = Instant::now();
        
        // 1. Build API request from query
        let url = format!("https://api.mysource.com/search?q={}", query.text);
        
        // 2. Make HTTP request with timeout
        let response = self.client
            .get(&url)
            .send()
            .await
            .map_err(|e| AdapterError::Network(e.to_string()))?;
        
        // 3. Parse response
        let data: serde_json::Value = response
            .json()
            .await
            .map_err(|e| AdapterError::Parse(e.to_string()))?;
        
        // 4. Return structured result
        Ok(SourceResult {
            source: self.name().to_string(),
            success: true,
            latency_ms: start.elapsed().as_millis() as u64,
            data: Some(data),
            error: None,
            confidence: 0.8,  // How reliable is this source?
            relevance: 0.9,   // How relevant to the query?
        })
    }
    
    fn can_handle(&self, query: &Query) -> bool {
        // Return true if this adapter can handle the query intent
        query.intent == "my_intent"
    }
    
    fn rate_limit(&self) -> u32 {
        100 // requests per second
    }
    
    fn timeout_ms(&self) -> u64 {
        500 // milliseconds
    }
}
```

Then register it in `src/orchestrator.rs`:

```rust
adapters.push(Arc::new(MySourceAdapter::new()?));
```

## 🎯 Adapter Priority List

### Phase 2 (50 adapters) - Month 1-3

**Web Search (5)**
1. ✅ Wikipedia
2. 🔄 Google Search
3. ⏳ Bing Search
4. ⏳ DuckDuckGo
5. ⏳ Brave Search

**Weather (5)**
1. 🔄 OpenWeather
2. 🔄 Weather API
3. ⏳ Weather.gov
4. ⏳ AccuWeather
5. ⏳ Dark Sky

**News (5)**
1. 🔄 News API
2. ⏳ BBC News
3. ⏳ CNN
4. ⏳ Reuters
5. ⏳ AP News

**Social Media (5)**
1. ⏳ Twitter/X
2. ⏳ Reddit
3. ⏳ LinkedIn
4. ⏳ YouTube
5. ⏳ Hacker News

**Knowledge (5)**
1. ⏳ Wikidata
2. ⏳ DBpedia
3. ⏳ Wolfram Alpha
4. ⏳ Stack Overflow
5. ⏳ Quora

... (25 more)

## 🔐 Security

- **API Keys**: Stored in environment variables, never in code
- **Rate Limiting**: Per-source rate limits to avoid bans
- **Timeout Protection**: Every request has a timeout
- **Error Handling**: Graceful degradation, never crash
- **Privacy**: User queries are not logged (only anonymized metrics)

## 📊 Metrics

```prometheus
# Query metrics
universal_connector_queries_total{source="wikipedia",status="success"} 1523
universal_connector_query_duration_seconds{source="wikipedia",quantile="0.95"} 0.342

# Cache metrics
universal_connector_cache_hits_total{tier="l1"} 8234
universal_connector_cache_hits_total{tier="l2"} 2341
universal_connector_cache_misses_total 1523

# Source health
universal_connector_source_available{source="wikipedia"} 1
universal_connector_source_available{source="google_search"} 0
```

## 🐛 Debugging

```bash
# Enable debug logging
export RUST_LOG=universal_connector=debug

# Run with verbose output
cargo run

# Watch logs
tail -f /var/log/universal-connector/app.log

# Check Redis cache
redis-cli KEYS "query:*"
redis-cli GET "query:What is AI?"

# Monitor health
watch -n 1 curl http://localhost:8080/health
```

## 🧪 Testing

```bash
# Run unit tests
cargo test

# Run integration tests
cargo test --features integration

# Load test
hey -n 10000 -c 100 -m POST \
  -H "Content-Type: application/json" \
  -d '{"text":"test","intent":"search","entities":{},"sources":[]}' \
  http://localhost:8080/query
```

## 📚 Related Documentation

- **[Core Philosophy](../../docs/philosophy/CORE_PHILOSOPHY.md)** - The "AI as Air" vision
- **[Architecture Overview](../../docs/architecture/OVERVIEW.md)** - System architecture
- **[API Reference](../../docs/guides/API_REFERENCE.md)** - Full API documentation

## 🚀 Next Steps

1. **Complete Phase 2 Adapters** (50 total)
   - Implement Google Search
   - Implement Weather APIs
   - Implement News sources
   - Add social media sources

2. **Improve Performance**
   - Add circuit breaker pattern
   - Implement adaptive timeouts
   - Optimize parallel fetching
   - Add Prometheus metrics

3. **Scale Infrastructure**
   - Deploy to Kubernetes
   - Add horizontal auto-scaling
   - Set up Redis cluster
   - Configure load balancing

---

**Version**: 0.1.0  
**Status**: Active Development - Phase 1  
**Language**: Rust  
**Framework**: Axum  
**License**: Proprietary

**"Making data access as natural as breathing"** 🌬️
