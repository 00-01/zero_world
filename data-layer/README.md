# Data Layer Architecture

## Overview
Data layer designed to handle 1 trillion users with 100,000+ database shards across multiple regions.

## Architecture Components

```
data-layer/
├── sharding/                    # Sharding strategy and management
│   ├── consistent-hashing/     # Consistent hashing implementation
│   ├── shard-manager/          # Shard allocation and rebalancing
│   ├── routing-service/        # Query routing to correct shards
│   └── migration-tools/        # Data migration between shards
├── databases/                   # Database configurations
│   ├── postgresql/             # PostgreSQL clusters (100K shards)
│   ├── mongodb/                # MongoDB clusters (document store)
│   ├── cassandra/              # Cassandra clusters (time-series)
│   ├── redis/                  # Redis clusters (caching)
│   └── neo4j/                  # Graph database (relationships)
├── caching/                     # Multi-tier caching strategy
│   ├── l1-local/               # In-memory cache (application level)
│   ├── l2-distributed/         # Redis distributed cache
│   └── l3-cdn/                 # CDN edge caching
├── search/                      # Search infrastructure
│   ├── elasticsearch/          # Full-text search
│   └── algolia/                # Instant search
└── analytics/                   # Analytics databases
    ├── clickhouse/             # OLAP queries
    ├── bigquery/               # Big data analytics
    └── snowflake/              # Data warehousing
```

## Database Sharding Strategy

### Shard Distribution

```
Total Shards: 100,000
Users per Shard: 10,000,000 (10M)
Total Capacity: 1,000,000,000,000 (1T users)

Shard Allocation by Region:
- North America: 30,000 shards (300B users)
- Asia Pacific:  35,000 shards (350B users)
- Europe:        20,000 shards (200B users)
- Latin America: 8,000 shards  (80B users)
- Middle East:   4,000 shards  (40B users)
- Africa:        3,000 shards  (30B users)
```

### Sharding Keys

#### User Data (by User ID)
```sql
-- Consistent hashing: user_id → shard_id
shard_id = consistent_hash(user_id) % 100000

-- Example:
user_id: "usr_742a9b3c" → hash: 42857 → shard_id: 42857
```

#### Chat Messages (by Conversation ID)
```sql
-- Keep conversation messages together
shard_id = consistent_hash(conversation_id) % 100000

-- Co-locate with user shard for efficiency
primary_shard = consistent_hash(user1_id) % 100000
replica_shard = consistent_hash(user2_id) % 100000
```

#### Content Data (by Content ID + Timestamp)
```sql
-- Time-based sharding for analytics
shard_id = (consistent_hash(content_id) + date_bucket) % 100000

-- Date buckets: daily for recent data, weekly for old data
```

### Shard Manager Service

```go
package shardmanager

import (
    "context"
    "hash/crc32"
)

type ShardManager struct {
    totalShards  int
    shardMap     map[uint32]ShardInfo
    virtualNodes int // For consistent hashing
}

type ShardInfo struct {
    ShardID       int
    Region        string
    DataCenter    string
    PrimaryHost   string
    ReplicaHosts  []string
    Status        string // active, readonly, maintenance
    Capacity      int64  // Max users
    CurrentLoad   int64  // Current users
}

func NewShardManager(totalShards int) *ShardManager {
    return &ShardManager{
        totalShards:  totalShards,
        shardMap:     make(map[uint32]ShardInfo),
        virtualNodes: 150, // Balance load distribution
    }
}

// GetShard returns shard information for a given key
func (sm *ShardManager) GetShard(ctx context.Context, key string) (*ShardInfo, error) {
    hash := crc32.ChecksumIEEE([]byte(key))
    shardID := int(hash % uint32(sm.totalShards))
    
    shard, exists := sm.shardMap[uint32(shardID)]
    if !exists {
        return nil, ErrShardNotFound
    }
    
    // Check shard health
    if shard.Status != "active" {
        // Failover to replica
        return sm.getReplicaShard(ctx, shardID)
    }
    
    return &shard, nil
}

// RebalanceShards redistributes data across shards
func (sm *ShardManager) RebalanceShards(ctx context.Context) error {
    // Find overloaded shards (> 90% capacity)
    overloaded := sm.findOverloadedShards()
    
    // Find underutilized shards (< 50% capacity)
    underutilized := sm.findUnderutilizedShards()
    
    // Migrate data from overloaded to underutilized
    for _, src := range overloaded {
        for _, dst := range underutilized {
            if err := sm.migrateData(ctx, src, dst); err != nil {
                return err
            }
        }
    }
    
    return nil
}
```

## Database Technologies

### PostgreSQL (Primary Relational DB)

**Configuration:**
```yaml
postgresql:
  version: "15.4"
  total_shards: 100000
  replication_factor: 3  # 1 primary + 2 replicas
  
  instance_size:
    cpu: 64
    memory: 512GB
    storage: 10TB NVMe SSD
  
  connection_pool:
    max_connections: 10000
    pool_size: 500
    
  performance:
    shared_buffers: 128GB
    effective_cache_size: 384GB
    work_mem: 256MB
    maintenance_work_mem: 2GB
    
  backup:
    wal_level: logical
    max_wal_size: 10GB
    continuous_archiving: true
    point_in_time_recovery: true
```

**Schema Example:**
```sql
-- Sharded users table
CREATE TABLE users_shard_{SHARD_ID} (
    user_id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    metadata JSONB
);

CREATE INDEX idx_users_email ON users_shard_{SHARD_ID}(email);
CREATE INDEX idx_users_created ON users_shard_{SHARD_ID}(created_at);
CREATE INDEX idx_users_status ON users_shard_{SHARD_ID}(status) WHERE status = 'active';

-- Sharded messages table
CREATE TABLE messages_shard_{SHARD_ID} (
    message_id UUID PRIMARY KEY,
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    edited_at TIMESTAMP,
    deleted_at TIMESTAMP,
    metadata JSONB
) PARTITION BY RANGE (created_at);

-- Monthly partitions for better query performance
CREATE TABLE messages_shard_{SHARD_ID}_2025_10 PARTITION OF messages_shard_{SHARD_ID}
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
```

### MongoDB (Document Store)

**Configuration:**
```yaml
mongodb:
  version: "7.0"
  sharded_clusters: 10000
  shards_per_cluster: 10
  total_shards: 100000
  
  replica_set_size: 3
  
  instance_size:
    cpu: 48
    memory: 384GB
    storage: 20TB
    
  performance:
    wiredTiger_cache: 256GB
    connections: 50000
    
  use_cases:
    - User profiles (flexible schema)
    - Chat metadata
    - Event logs
    - Session data
```

**Schema Example:**
```javascript
// User profile collection (flexible schema)
db.user_profiles.insertOne({
    _id: ObjectId("507f1f77bcf86cd799439011"),
    user_id: "usr_742a9b3c",
    display_name: "John Doe",
    bio: "Software engineer",
    avatar_url: "https://cdn.zeroworld.com/avatars/...",
    preferences: {
        theme: "dark",
        language: "en",
        notifications: {
            email: true,
            push: true,
            sms: false
        }
    },
    social_links: [
        { platform: "twitter", url: "https://twitter.com/..." },
        { platform: "github", url: "https://github.com/..." }
    ],
    created_at: ISODate("2025-01-15T10:30:00Z"),
    updated_at: ISODate("2025-10-15T14:22:00Z")
});

// Indexes
db.user_profiles.createIndex({ user_id: 1 }, { unique: true });
db.user_profiles.createIndex({ "preferences.theme": 1 });
db.user_profiles.createIndex({ created_at: -1 });
```

### Cassandra (Time-Series Data)

**Configuration:**
```yaml
cassandra:
  version: "4.1"
  nodes_per_datacenter: 1000
  datacenters: 50
  total_nodes: 50000
  
  replication_factor: 3
  consistency_level: QUORUM
  
  instance_size:
    cpu: 32
    memory: 256GB
    storage: 50TB
    
  use_cases:
    - Activity logs
    - Analytics events
    - Time-series metrics
    - Audit trails
```

**Schema Example:**
```cql
-- Activity log (optimized for time-series queries)
CREATE TABLE activity_logs (
    user_id UUID,
    activity_date DATE,
    activity_time TIMESTAMP,
    activity_type TEXT,
    activity_data MAP<TEXT, TEXT>,
    ip_address INET,
    user_agent TEXT,
    PRIMARY KEY ((user_id, activity_date), activity_time)
) WITH CLUSTERING ORDER BY (activity_time DESC)
  AND compaction = {'class': 'TimeWindowCompactionStrategy', 
                     'compaction_window_size': 1, 
                     'compaction_window_unit': 'DAYS'};

-- Efficient queries
SELECT * FROM activity_logs 
WHERE user_id = ? AND activity_date = ? 
ORDER BY activity_time DESC 
LIMIT 100;
```

### Redis (Distributed Cache)

**Configuration:**
```yaml
redis:
  version: "7.2"
  clusters: 10000
  nodes_per_cluster: 20
  total_nodes: 200000
  
  instance_size:
    cpu: 32
    memory: 256GB
    
  persistence:
    rdb_snapshots: true
    aof_enabled: true
    
  eviction_policy: allkeys-lru
  max_memory_policy: 230GB  # 90% of available
  
  use_cases:
    - Session storage
    - API response cache
    - Rate limiting counters
    - Real-time leaderboards
    - Pub/Sub messaging
```

**Usage Example:**
```go
// Cache user session
func CacheUserSession(ctx context.Context, userID string, session *Session) error {
    key := fmt.Sprintf("session:%s", userID)
    data, _ := json.Marshal(session)
    
    // Set with 24-hour expiration
    return redisClient.Set(ctx, key, data, 24*time.Hour).Err()
}

// Rate limiting
func CheckRateLimit(ctx context.Context, userID string, limit int) (bool, error) {
    key := fmt.Sprintf("ratelimit:%s", userID)
    
    count, err := redisClient.Incr(ctx, key).Result()
    if err != nil {
        return false, err
    }
    
    if count == 1 {
        // First request, set expiration
        redisClient.Expire(ctx, key, time.Minute)
    }
    
    return count <= int64(limit), nil
}
```

### Neo4j (Graph Database)

**Configuration:**
```yaml
neo4j:
  version: "5.12"
  clusters: 1000
  nodes_per_cluster: 10
  total_nodes: 10000
  
  instance_size:
    cpu: 64
    memory: 512GB
    storage: 10TB
    
  use_cases:
    - Social graph (friends, followers)
    - Content recommendations
    - Fraud detection
    - Knowledge graph
```

**Schema Example:**
```cypher
// User relationships
CREATE (u:User {
    id: 'usr_742a9b3c',
    username: 'johndoe',
    created_at: datetime()
})

// Friendships
MATCH (u1:User {id: 'usr_742a9b3c'})
MATCH (u2:User {id: 'usr_8d3e9f1a'})
CREATE (u1)-[:FRIEND {since: datetime()}]->(u2)

// Find friends of friends
MATCH (u:User {id: 'usr_742a9b3c'})-[:FRIEND]->(friend)-[:FRIEND]->(fof)
WHERE NOT (u)-[:FRIEND]->(fof) AND u <> fof
RETURN fof.username, COUNT(friend) as mutual_friends
ORDER BY mutual_friends DESC
LIMIT 20
```

## Multi-Tier Caching Strategy

### L1: Application-Level Cache (In-Memory)
```
Technology: Local cache (sync.Map, caffeine)
TTL: 1-5 minutes
Hit Rate: 90%+
Latency: < 1ms
Size: 1-10 GB per instance
```

### L2: Distributed Cache (Redis)
```
Technology: Redis Cluster
TTL: 5 minutes - 24 hours
Hit Rate: 85%+
Latency: < 5ms
Size: 10-100 TB total
```

### L3: CDN Edge Cache (CloudFront/Cloudflare)
```
Technology: CloudFront, Cloudflare
TTL: 1 hour - 7 days
Hit Rate: 95%+ (static content)
Latency: < 50ms
Size: Unlimited (edge locations)
```

### Cache Hierarchy
```
Request Flow:
1. Check L1 (app memory) → 90% hit rate
2. If miss, check L2 (Redis) → 85% hit rate
3. If miss, check L3 (CDN) → 95% hit rate
4. If miss, query database

Combined hit rate: 99.8%
Database queries: 0.2% of requests
```

## Data Migration Tools

### Zero-Downtime Migration
```go
type MigrationManager struct {
    source      ShardInfo
    destination ShardInfo
    batchSize   int
}

func (mm *MigrationManager) MigrateData(ctx context.Context) error {
    // Phase 1: Setup replication
    if err := mm.setupReplication(); err != nil {
        return err
    }
    
    // Phase 2: Bulk copy (old data)
    if err := mm.bulkCopy(ctx); err != nil {
        return err
    }
    
    // Phase 3: Sync recent changes
    if err := mm.syncRecentChanges(ctx); err != nil {
        return err
    }
    
    // Phase 4: Switch reads to destination
    if err := mm.switchReads(); err != nil {
        return err
    }
    
    // Phase 5: Switch writes to destination
    if err := mm.switchWrites(); err != nil {
        return err
    }
    
    // Phase 6: Verify and cleanup
    if err := mm.verifyAndCleanup(ctx); err != nil {
        return err
    }
    
    return nil
}
```

## Backup & Recovery

### Backup Strategy
```yaml
continuous_backup:
  postgresql:
    wal_archiving: every_10_seconds
    base_backup: daily
    retention: 30_days
    
  mongodb:
    oplog_tailing: real_time
    snapshot: every_6_hours
    retention: 14_days
    
  cassandra:
    incremental_backup: hourly
    full_backup: daily
    retention: 7_days

cross_region_replication:
  enabled: true
  lag_target: less_than_1_minute
  
disaster_recovery:
  rpo: 10_seconds  # Recovery Point Objective
  rto: 5_minutes   # Recovery Time Objective
```

## Monitoring & Observability

### Key Metrics
```
Database Performance:
- Query latency (P50, P95, P99)
- Queries per second
- Connection pool utilization
- Replication lag
- Cache hit rate
- Slow query count

Shard Health:
- Shard capacity utilization
- Data distribution balance
- Hot shard detection
- Failed shards
- Migration progress

Business Metrics:
- Active users per shard
- Data growth rate
- Storage utilization
- Backup success rate
```

---

**Data layer designed to handle exabytes of data across 100,000+ shards with sub-10ms latency.**
