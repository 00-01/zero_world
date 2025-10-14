// ============================================
// COMPLETE SOCIAL NETWORKING PLATFORM
// ============================================

// USER PROFILES
class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String profilePicture;
  final String coverPhoto;
  final DateTime birthDate;
  final String location;
  final String website;
  final int followers;
  final int following;
  final int posts;
  final bool verified;
  final DateTime joinedDate;
  final Map<String, dynamic> privacy;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.profilePicture,
    required this.coverPhoto,
    required this.birthDate,
    required this.location,
    required this.website,
    required this.followers,
    required this.following,
    required this.posts,
    required this.verified,
    required this.joinedDate,
    required this.privacy,
  });
}

// POSTS (Timeline/Feed)
class SocialPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> images;
  final List<String> videos;
  final String location;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isBookmarked;
  final String privacy; // public, friends, private
  final List<String> mentions;
  final List<String> hashtags;

  const SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.images,
    required this.videos,
    required this.location,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isBookmarked,
    required this.privacy,
    required this.mentions,
    required this.hashtags,
  });
}

// STORIES (24-hour disappearing content)
class Story {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String type; // image, video, text
  final String content;
  final DateTime timestamp;
  final int views;
  final List<String> viewers;
  final bool viewed;

  const Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.views,
    required this.viewers,
    required this.viewed,
  });
}

// COMMENTS
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<Comment> replies;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    required this.isLiked,
  });
}

// GROUPS
class SocialGroup {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final String privacy; // public, private, secret
  final int members;
  final String category;
  final List<String> admins;
  final List<String> moderators;
  final DateTime createdDate;
  final List<String> rules;

  const SocialGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.privacy,
    required this.members,
    required this.category,
    required this.admins,
    required this.moderators,
    required this.createdDate,
    required this.rules,
  });
}

// PAGES (Business/Brand Pages)
class SocialPage {
  final String id;
  final String name;
  final String category;
  final String description;
  final String profilePicture;
  final String coverPhoto;
  final int followers;
  final bool verified;
  final String website;
  final String phone;
  final String email;
  final String address;
  final Map<String, String> hours;
  final double rating;
  final int reviews;

  const SocialPage({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.profilePicture,
    required this.coverPhoto,
    required this.followers,
    required this.verified,
    required this.website,
    required this.phone,
    required this.email,
    required this.address,
    required this.hours,
    required this.rating,
    required this.reviews,
  });
}

// EVENTS
class SocialEvent {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String organizerId;
  final int going;
  final int interested;
  final bool isGoing;
  final bool isInterested;
  final String privacy;
  final List<String> coHosts;

  const SocialEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizerId,
    required this.going,
    required this.interested,
    required this.isGoing,
    required this.isInterested,
    required this.privacy,
    required this.coHosts,
  });
}

// MESSAGING
class Conversation {
  final String id;
  final String type; // direct, group
  final String name;
  final String avatar;
  final List<String> participants;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;

  const Conversation({
    required this.id,
    required this.type,
    required this.name,
    required this.avatar,
    required this.participants,
    required this.lastMessage,
    required this.unreadCount,
    required this.isPinned,
    required this.isMuted,
  });
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final String type; // text, image, video, audio, file, location, contact
  final List<String> attachments;
  final DateTime timestamp;
  final bool isRead;
  final List<String> readBy;
  final Message? replyTo;
  final List<MessageReaction> reactions;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.type,
    required this.attachments,
    required this.timestamp,
    required this.isRead,
    required this.readBy,
    this.replyTo,
    required this.reactions,
  });
}

class MessageReaction {
  final String userId;
  final String emoji;

  const MessageReaction({required this.userId, required this.emoji});
}

// VIDEO/VOICE CALLS
class Call {
  final String id;
  final String type; // voice, video
  final String callType; // incoming, outgoing, missed
  final List<String> participants;
  final DateTime timestamp;
  final int duration;
  final bool isGroupCall;

  const Call({
    required this.id,
    required this.type,
    required this.callType,
    required this.participants,
    required this.timestamp,
    required this.duration,
    required this.isGroupCall,
  });
}

// LIVE STREAMING
class LiveStream {
  final String id;
  final String streamerId;
  final String streamerName;
  final String streamerAvatar;
  final String title;
  final String thumbnail;
  final int viewers;
  final DateTime startedAt;
  final List<String> tags;
  final bool isLive;

  const LiveStream({
    required this.id,
    required this.streamerId,
    required this.streamerName,
    required this.streamerAvatar,
    required this.title,
    required this.thumbnail,
    required this.viewers,
    required this.startedAt,
    required this.tags,
    required this.isLive,
  });
}

// NOTIFICATIONS
class SocialNotification {
  final String id;
  final String
  type; // like, comment, share, follow, mention, group-invite, event-invite
  final String actorId;
  final String actorName;
  final String actorAvatar;
  final String content;
  final String targetId;
  final String targetType; // post, comment, profile, group, event
  final DateTime timestamp;
  final bool isRead;

  const SocialNotification({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.actorAvatar,
    required this.content,
    required this.targetId,
    required this.targetType,
    required this.timestamp,
    required this.isRead,
  });
}

// FRIEND REQUESTS
class FriendRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final int mutualFriends;
  final DateTime timestamp;
  final String status; // pending, accepted, rejected

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.mutualFriends,
    required this.timestamp,
    required this.status,
  });
}

// ALBUMS
class PhotoAlbum {
  final String id;
  final String name;
  final String coverPhoto;
  final int photoCount;
  final DateTime createdDate;
  final String privacy;
  final String ownerId;

  const PhotoAlbum({
    required this.id,
    required this.name,
    required this.coverPhoto,
    required this.photoCount,
    required this.createdDate,
    required this.privacy,
    required this.ownerId,
  });
}

// POLLS
class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final DateTime endTime;
  final String votedOption;
  final bool allowMultiple;

  const Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.totalVotes,
    required this.endTime,
    required this.votedOption,
    required this.allowMultiple,
  });
}

class PollOption {
  final String id;
  final String text;
  final int votes;
  final double percentage;

  const PollOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.percentage,
  });
}

// HASHTAGS & TRENDS
class Hashtag {
  final String tag;
  final int posts;
  final String category;
  final bool trending;

  const Hashtag({
    required this.tag,
    required this.posts,
    required this.category,
    required this.trending,
  });
}

// CHECK-INS
class CheckIn {
  final String id;
  final String userId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String postId;

  const CheckIn({
    required this.id,
    required this.userId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.postId,
  });
}

// MOMENTS (WeChat-style photo sharing)
class Moment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> images;
  final String location;
  final DateTime timestamp;
  final List<MomentComment> comments;
  final List<String> likes;
  final String privacy;

  const Moment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.images,
    required this.location,
    required this.timestamp,
    required this.comments,
    required this.likes,
    required this.privacy,
  });
}

class MomentComment {
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  const MomentComment({
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });
}

// SAVED POSTS
class SavedPost {
  final String id;
  final String postId;
  final String collection; // default or custom collection name
  final DateTime savedDate;

  const SavedPost({
    required this.id,
    required this.postId,
    required this.collection,
    required this.savedDate,
  });
}

// BLOCKED USERS
class BlockedUser {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final DateTime blockedDate;

  const BlockedUser({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.blockedDate,
  });
}

// REPORTED CONTENT
class Report {
  final String id;
  final String reporterId;
  final String contentId;
  final String contentType; // post, comment, user, message
  final String reason;
  final String description;
  final DateTime timestamp;
  final String status; // pending, reviewed, resolved

  const Report({
    required this.id,
    required this.reporterId,
    required this.contentId,
    required this.contentType,
    required this.reason,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}

// RECOMMENDATIONS
class Recommendation {
  final String id;
  final String type; // friend, page, group, event
  final String targetId;
  final String targetName;
  final String targetAvatar;
  final String reason;
  final int mutualConnections;

  const Recommendation({
    required this.id,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.targetAvatar,
    required this.reason,
    required this.mutualConnections,
  });
}

// MEMORIES (On This Day feature)
class Memory {
  final String id;
  final String postId;
  final int yearsAgo;
  final DateTime originalDate;

  const Memory({
    required this.id,
    required this.postId,
    required this.yearsAgo,
    required this.originalDate,
  });
}
