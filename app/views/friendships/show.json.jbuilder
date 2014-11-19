json.extract! @friendship, :user1_id, :user2_id, :authorized
json.user1_name @friendship.user1.username
json.user2_name @friendship.user2.username
json.friendship_id @friendship.id
