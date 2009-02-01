class LoginToken < SecureToken
  belongs_to :user  
  validates_presence_of :user_id
end
