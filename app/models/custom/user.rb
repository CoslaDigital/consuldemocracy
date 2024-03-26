require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord

  validates :email, presence: true, if: -> { unconfirmed_phone.blank? }
  validates :unconfirmed_phone, presence: true, if: -> { email.blank? }
  validate :document_number_format

  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)
  Rails.logger.info('Attributes in auth.info:')
    auth.info.each do |key, value|
    Rails.logger.info("#{key}: #{value}")
  end

    oauth_email           = auth.info.email
    oauth_verified        = auth.info.verified || auth.info.verified_email || auth.info.email_verified || auth.extra.raw_info.email_verified
    # following line assumes oauth provider has verified email
    oauth_email_confirmed = oauth_email.present? #&& oauth_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_user || User.new(
      username:  auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil,
      verified_at: DateTime.current ,
      residence_verified_at:  DateTime.current
    )
  end
  
 def erase(erase_reason = nil)
    update!(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil,
      document_number: nil
    )
    identities.destroy_all
    remove_roles
  end
  
   def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email, :unconfirmed_phone, :document_number])
    end


# Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_saml(auth)

# Assuming 'auth.extra.raw_info' is the OneLogin::RubySaml::Attributes object
attributes = auth.extra.raw_info.attributes


# Define a mapping of attribute names to OID values
attribute_mapping = {
  "saml_username" => "urn:oid:0.9.2342.19200300.100.1.1",
  "saml_authority_code" => "urn:oid:0.9.2342.19200300.100.1.17",
  "saml_firstname" => "urn:oid:0.9.2342.19200300.100.1.2",
  "saml_surname" => "urn:oid:0.9.2342.19200300.100.1.4",
  "saml_latitude" => "urn:oid:0.9.2342.19200300.100.1.33",
  "saml_longitude" => "urn:oid:0.9.2342.19200300.100.1.34",
  "saml_date_of_birth" => "urn:oid:0.9.2342.19200300.100.1.8",
  "saml_gender" => "urn:oid:0.9.2342.19200300.100.1.9",
  "saml_postcode" => "urn:oid:0.9.2342.19200300.100.1.16",
  "saml_email" => "urn:oid:0.9.2342.19200300.100.1.22",
  "saml_town" => "urn:oid:0.9.2342.19200300.100.1.15",
  "saml_add1" => "urn:oid:0.9.2342.19200300.100.1.12",
  "saml_5" => "urn:oid:0.9.2342.19200300.100.1.5",
  "saml_6" => "urn:oid:0.9.2342.19200300.100.1.6",
  "saml_7" => "urn:oid:0.9.2342.19200300.100.1.7",
  "saml_assurance" => "urn:oid:0.9.2342.19200300.100.1.20",
  "saml_10" => "urn:oid:0.9.2342.19200300.100.1.10"
}

# Initialize a hash to store the extracted values
extracted_values = {}

# Iterate through the attribute mapping and extract values
attribute_mapping.each do |attribute_name, oid_value|
  if attributes[oid_value]
    extracted_values[attribute_name] = attributes[oid_value][0]
  end
end

# Now you have a hash containing the extracted values
Rails.logger.info("extracted values: #{extracted_values.inspect}")

    # Assuming 'extracted_values' is the hash containing extracted values
    saml_username = extracted_values["saml_username"]
    saml_authority_code = extracted_values["saml_authority_code"]
    saml_firstname = extracted_values["saml_firstname"]
    saml_surname = extracted_values["saml_surname"]
    saml_long = extracted_values["saml_longitude"]
    saml_lat = extracted_values["saml_latitude"]
    saml_date_of_birth = extracted_values["saml_date_of_birth"]
    saml_gender = extracted_values["saml_gender"]
    saml_postcode = extracted_values["saml_postcode"]
    saml_email = extracted_values["saml_email"]
    saml_town = extracted_values["saml_town"]

    oauth_email = saml_email
    oauth_gender = saml_gender
    oauth_username = saml_username
    oauth_lacode = saml_authority_code      
    saml_full_name = saml_firstname + "_" + saml_surname
    oauth_date_of_birth = saml_date_of_birth
    oauth_email_confirmed = oauth_email.present?
    saml_email_confirmed = saml_email.present?
   # oauth_email_confirmed = oauth_email.present? && (auth.info.verified || auth.info.verified_email)

   # Normalize the saml_postcode by stripping spaces and converting to lowercase
    normalized_saml_postcode = saml_postcode.strip.downcase if saml_postcode.present?
   
   #lacode comes from list of councils registered with IS
    oauth_lacode_ref          = "9079" # this should be picked up from secrets in future
    oauth_lacode_confirmed    = oauth_lacode == oauth_lacode_ref
    oauth_user            = User.find_by(email: saml_email) if saml_email_confirmed
   
   # Assign Geozone based on the normalized saml_postcode if it exists
   if normalized_saml_postcode.present?
   # Find the Postcode instance based on the normalized saml_postcode
   # This only goes in if Manage Postcodes is added
   #   postcode_instance = Postcode.find_by(postcode: normalized_saml_postcode)

#   if postcode_instance
    # Assign the associated Geozone to the user
    #  saml_user.geozone = postcode_instance.geozone
#   else
    # Handle the case when the postcode is not found
    #  saml_user.geozone = nil
#  end
   end
   
   # oauth_username = oauth_full_name ||  oauth_email.split("@").first || auth.info.name || auth.uid
   if saml_username.present? && saml_username != saml_email && saml_username != saml_full_name
      oauth_username = saml_username
   else
   # If the original value of oauth_username is the same as oauth_email or oauth_full_name, add a random number to obfuscate
      oauth_username = "#{saml_full_name}_#{rand(100..999)}"
   end
    oauth_user || User.new(
      username:  oauth_username,
      email: saml_email,
      date_of_birth: saml_date_of_birth,
      gender: saml_gender,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: DateTime.current,
      verified_at: DateTime.current ,
      residence_verified_at:  DateTime.current,
      geozone_id: saml_geozone_id
    )
  end


 # overwritting of Devise method to allow login using email OR username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_hash).find_by(["lower(email) = ?", login.downcase]) ||
    where(conditions.to_hash).find_by(["username = ?", login]) ||
    where(conditions.to_hash).find_by(["confirmed_phone = ?", login]) ||
    where(conditions.to_hash).find_by(["document_number = ?", login])
  end


 
  def send_devise_notification(notification, *args)
  Rails.logger.debug("notification is: #{notification} ")
  #this needs a more elegant solution to extract the server name from an attribute
  server_name = Rails.application.secrets.server_name
  protocol="http://"
  port=":3000"
  url = server_name+port+"/users/confirmation?confirmation_token="+args[0].to_s
 # nurl =  url_for(controller:'users/confirmations', action: 'create')
 # number to come from the phone field or the unconfirmed phone field
# the code must be associated with one of the tokens which seems to be hidden in the system and not used
  dummy_code = "REG"
  self.update!(sms_confirmation_code: dummy_code)
  Rails.logger.debug("args: #{args.inspect}") # Write the contents of the args parameter to the log file
  Rails.logger.debug("Got here insie ") # url_for gives this
  sms_api = SMSApi.new
#testing using unconfirmed phone
    sms_api.send_sms(unconfirmed_phone, username, url, dummy_code) if unconfirmed_phone?
    devise_mailer.send(notification, self, *args).deliver_later if email?
  end


 private


    def validate_document_number(document_number)
  return true if document_number.nil?


  valid_prefixes = { '6337' => true, '5678' => true, '9012' => true } # Example hash of valid prefixes

  # Check if the document number is 16 digits long
  return false unless document_number.to_s.length == 16

  # Extract the prefix, middle, and suffix parts of the document number
  prefix = document_number.to_s[0, 4]
  middle = document_number.to_s[4, 10]
  suffix = document_number.to_s[14, 2]

  # Check if the prefix exists in the valid prefixes hash
  return false unless valid_prefixes.key?(prefix)

  # Check if the middle and suffix parts are numeric
  return false unless middle.match?(/\A\d{10}\z/) && suffix.match?(/\A\d{2}\z/)

  # If all criteria are met, return true
  true
   end

    def document_number_format
    errors.add(:document_number, "is not valid") unless validate_document_number(document_number)
  end
   

    def clean_document_number
      return unless document_number.present?

      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase
    end

    def validate_username_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :username,
        maximum: User.username_max_length)
      validator.validate(self)
    end

    def phone_exists
    if unconfirmed_phone? || confirmed_phone?
    end

    def validate_email_or_phone
    if email.blank? && unconfirmed_phone.blank?
      errors.add(:email_or_phone, "must include either email or phone")
    end
  end

end
end
