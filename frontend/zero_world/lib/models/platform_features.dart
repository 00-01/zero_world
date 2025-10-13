// ============================================
// UNIVERSAL SEARCH ENGINE
// ============================================

class SearchResult {
  final String id;
  final String type; // user, post, group, page, event, listing, service, news, business
  final String title;
  final String description;
  final String thumbnail;
  final double relevanceScore;
  final Map<String, dynamic> data;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.relevanceScore,
    required this.data,
  });
}

class SearchFilter {
  final String type;
  final String location;
  final String dateRange;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy; // relevance, date, price, rating
  final Map<String, dynamic> customFilters;

  const SearchFilter({
    required this.type,
    required this.location,
    required this.dateRange,
    this.minPrice,
    this.maxPrice,
    required this.sortBy,
    required this.customFilters,
  });
}

class TrendingSearch {
  final String query;
  final String category;
  final int searchCount;
  final String region;

  const TrendingSearch({
    required this.query,
    required this.category,
    required this.searchCount,
    required this.region,
  });
}

class SearchSuggestion {
  final String text;
  final String type;
  final int popularity;

  const SearchSuggestion({
    required this.text,
    required this.type,
    required this.popularity,
  });
}

// ============================================
// AI RECOMMENDATIONS & PERSONALIZATION
// ============================================

class PersonalizedFeed {
  final String userId;
  final List<String> interests;
  final List<String> recentSearches;
  final Map<String, double> categoryWeights;
  final List<String> followedTopics;

  const PersonalizedFeed({
    required this.userId,
    required this.interests,
    required this.recentSearches,
    required this.categoryWeights,
    required this.followedTopics,
  });
}

class ContentRecommendation {
  final String id;
  final String contentId;
  final String contentType;
  final double score;
  final String reason;

  const ContentRecommendation({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.score,
    required this.reason,
  });
}

// ============================================
// ANALYTICS & INSIGHTS
// ============================================

class UserAnalytics {
  final String userId;
  final Map<String, int> activityByHour;
  final Map<String, int> activityByDay;
  final List<String> topInterests;
  final double engagementRate;
  final Map<String, dynamic> demographics;

  const UserAnalytics({
    required this.userId,
    required this.activityByHour,
    required this.activityByDay,
    required this.topInterests,
    required this.engagementRate,
    required this.demographics,
  });
}

class BusinessInsights {
  final String businessId;
  final int totalReach;
  final int totalEngagement;
  final int newFollowers;
  final Map<String, int> topPosts;
  final Map<String, double> audienceDemographics;
  final List<String> growthOpportunities;

  const BusinessInsights({
    required this.businessId,
    required this.totalReach,
    required this.totalEngagement,
    required this.newFollowers,
    required this.topPosts,
    required this.audienceDemographics,
    required this.growthOpportunities,
  });
}

// ============================================
// ADVERTISING PLATFORM
// ============================================

class Advertisement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final String targetUrl;
  final String category;
  final Map<String, dynamic> targeting;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final int impressions;
  final int clicks;
  final double ctr;

  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.targetUrl,
    required this.category,
    required this.targeting,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.impressions,
    required this.clicks,
    required this.ctr,
  });
}

class AdCampaign {
  final String id;
  final String name;
  final List<Advertisement> ads;
  final double totalBudget;
  final double spent;
  final String objective; // awareness, engagement, conversion
  final Map<String, dynamic> performance;

  const AdCampaign({
    required this.id,
    required this.name,
    required this.ads,
    required this.totalBudget,
    required this.spent,
    required this.objective,
    required this.performance,
  });
}

// ============================================
// SUBSCRIPTIONS & MEMBERSHIPS
// ============================================

class Subscription {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval; // monthly, yearly
  final List<String> features;
  final bool active;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // active, cancelled, expired

  const Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.features,
    required this.active,
    required this.startDate,
    this.endDate,
    required this.status,
  });
}

class Membership {
  final String id;
  final String organizationId;
  final String tier; // basic, premium, vip
  final List<String> benefits;
  final double price;
  final DateTime joinDate;
  final int points;

  const Membership({
    required this.id,
    required this.organizationId,
    required this.tier,
    required this.benefits,
    required this.price,
    required this.joinDate,
    required this.points,
  });
}

// ============================================
// LOYALTY & REWARDS
// ============================================

class LoyaltyProgram {
  final String id;
  final String businessId;
  final String name;
  final int points;
  final String tier;
  final List<Reward> availableRewards;
  final List<Transaction> pointsHistory;

  const LoyaltyProgram({
    required this.id,
    required this.businessId,
    required this.name,
    required this.points,
    required this.tier,
    required this.availableRewards,
    required this.pointsHistory,
  });
}

class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String imageUrl;
  final bool available;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.imageUrl,
    required this.available,
  });
}

class Transaction {
  final String id;
  final DateTime date;
  final int points;
  final String type; // earned, redeemed
  final String description;

  const Transaction({
    required this.id,
    required this.date,
    required this.points,
    required this.type,
    required this.description,
  });
}

// ============================================
// VERIFICATION & TRUST
// ============================================

class Verification {
  final String userId;
  final bool identityVerified;
  final bool phoneVerified;
  final bool emailVerified;
  final bool addressVerified;
  final List<String> documents;
  final DateTime verifiedDate;

  const Verification({
    required this.userId,
    required this.identityVerified,
    required this.phoneVerified,
    required this.emailVerified,
    required this.addressVerified,
    required this.documents,
    required this.verifiedDate,
  });
}

class TrustScore {
  final String userId;
  final double score; // 0-100
  final int completedTransactions;
  final double averageRating;
  final int disputes;
  final List<String> badges;

  const TrustScore({
    required this.userId,
    required this.score,
    required this.completedTransactions,
    required this.averageRating,
    required this.disputes,
    required this.badges,
  });
}

// ============================================
// CUSTOMER SUPPORT
// ============================================

class SupportTicket {
  final String id;
  final String userId;
  final String category;
  final String subject;
  final String description;
  final String status; // open, in-progress, resolved, closed
  final String priority; // low, medium, high, urgent
  final DateTime createdDate;
  final DateTime? resolvedDate;
  final List<SupportMessage> messages;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdDate,
    this.resolvedDate,
    required this.messages,
  });
}

class SupportMessage {
  final String id;
  final String senderId;
  final String senderType; // user, agent, system
  final String content;
  final DateTime timestamp;
  final List<String> attachments;

  const SupportMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.timestamp,
    required this.attachments,
  });
}

// ============================================
// GAMIFICATION
// ============================================

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int points;
  final DateTime unlockedDate;
  final String category;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.points,
    required this.unlockedDate,
    required this.category,
  });
}

class Leaderboard {
  final String id;
  final String name;
  final String category;
  final String period; // daily, weekly, monthly, all-time
  final List<LeaderboardEntry> entries;

  const Leaderboard({
    required this.id,
    required this.name,
    required this.category,
    required this.period,
    required this.entries,
  });
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String userName;
  final String userAvatar;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.score,
  });
}

// ============================================
// CONTENT MODERATION
// ============================================

class ModerationRule {
  final String id;
  final String type; // spam, offensive, illegal
  final String action; // remove, warn, ban
  final String criteria;
  final bool autoApply;

  const ModerationRule({
    required this.id,
    required this.type,
    required this.action,
    required this.criteria,
    required this.autoApply,
  });
}

class ModerationAction {
  final String id;
  final String contentId;
  final String contentType;
  final String action;
  final String reason;
  final String moderatorId;
  final DateTime timestamp;

  const ModerationAction({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.action,
    required this.reason,
    required this.moderatorId,
    required this.timestamp,
  });
}
