class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates_presence_of :email

  has_many :rest_access_tokens
  has_many :user_translations
  has_many :context_texts
  has_many :translation_in_context_texts
  has_and_belongs_to_many :languages, join_table: :languages_users
  has_many :translations, through: :user_translations
  has_many :trainings
  has_many :user_qas

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    resttoken= RestAccessToken.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    if resttoken.user.blank?
      user = current_user || User.where('email = ?', auth["info"]["email"]).first
      if user.blank?
        user = User.new
        user.password = Devise.friendly_token[0,10]
        user.name = auth.info.name
        user.email = auth.info.email
        user.singed_via = auth.provider
        user.save
      end
      resttoken.user_id = user.id
      resttoken.save
    end
    resttoken.user
  end
end
