class UserSerializer < Blueprinter::Base
  identifier :id
  fields :name, :email, :role, :phone, :active, :last_login_at, :created_at
end
