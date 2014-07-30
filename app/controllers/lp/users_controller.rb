class Lp::UsersController < UsersController
  skip_before_filter :respond_to_suspicious_request, only: [:create, :find]

  def find
    render json: User.find_by_email!(params[:email])
  end

  def create
    resp = { errors: [], user: nil }

    begin
      ActiveRecord::Base.connection.transaction do
        user_params            = params[:user]
        user_params[:name]     = User.suggest_name(user_params[:name] || user_params[:username] || user_params[:email])
        user_params[:username] = UserNameSuggester.suggest(user_params[:username] || user_params[:name] || user_params[:email])

        # create or update
        new_user = User.find_or_initialize_by(email: Email.downcase(user_params[:email])) do |u|
          u.name       = user_params[:name]
          u.username   = user_params[:username]
          u.active     = true
          u.created_at = user_params[:created_at]
          u.updated_at = user_params[:updated_at]
          u.bio_raw    = user_params[:user_bio] || ''
        end

        new_user.save!

        resp[:user] = { id: new_user.id, name: new_user.name, username: new_user.username, email: new_user.email }
      end
    rescue Exception => e
      resp[:errors] = { exception: "#{e.class} #{e.message}", backtrace: e.backtrace }
    end

    render json: MultiJson.dump(resp), status: resp[:errors].present? ? 422 : 200
  end
end
