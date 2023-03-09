# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        },
        {
          url: 'http://localhost:3000',
          description: 'Local development'
        }
      ],
      components: {
        securitySchemes: {
          bearer: {
            type: :http,
            scheme: :bearer
          }
        },
        schemas: {
          new_random_thought: {
            type: 'object',
            properties: {
              thought: { type: 'string', minLength: 1 },
              name: { type: 'string', minLength: 1 }
            },
            required: %w[thought name]
          },
          create_random_thought: {
            type: 'object',
            properties: {
              random_thought: { '$ref' => '#/components/schemas/new_random_thought' }
            },
            required: %w[random_thought]
          },
          random_thought_response: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              thought: { type: 'string' },
              name: { type: 'string' }
            },
            required: %w[id thought name]
          },
          updated_random_thought: {
            type: 'object',
            properties: {
              thought: { type: 'string', minLength: 1 },
              name: { type: 'string', minLength: 1 }
            }
          },
          update_random_thought: {
            type: 'object',
            properties: {
              random_thought: { '$ref' => '#/components/schemas/updated_random_thought' }
            },
            required: %w[random_thought]
          },
          paginated_random_thoughts: {
            type: 'object',
            properties: {
              data: {
                type: :array,
                items: { '$ref' => '#/components/schemas/random_thought_response' }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination'
              }
            },
            required: %w[data meta]
          },
          new_user: {
            type: 'object',
            properties: {
              email: { type: 'string', minLength: 1, maxLength: 254 },
              display_name: { type: 'string', minLength: 1 },
              password: { type: 'string', minLength: User::PASSWORD_MIN_LENGTH },
              password_confirmation: { type: 'string', minLength: User::PASSWORD_MIN_LENGTH }
            },
            required: %w[email display_name password password_confirmation]
          },
          create_user: {
            type: 'object',
            properties: {
              user: { '$ref' => '#/components/schemas/new_user' }
            }
          },
          same_user_response: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              email: { type: 'string', minLength: 1, maxLength: 254 },
              display_name: { type: 'string', minLength: 1 }
            },
            required: %w[id email display_name]
          },
          different_user_response: {
            type: 'object',
            properties: {
              display_name: { type: 'string', minLength: 1 }
            },
            required: %w[display_name]
          },
          updated_user: {
            type: 'object',
            properties: {
              email: { type: 'string', minLength: 1, maxLength: 254 },
              display_name: { type: 'string', minLength: 1 },
              password: { type: 'string', minLength: User::PASSWORD_MIN_LENGTH },
              password_confirmation: { type: 'string', minLength: User::PASSWORD_MIN_LENGTH }
            }
          },
          update_user: {
            type: 'object',
            properties: {
              user: { '$ref' => '#/components/schemas/updated_user' }
            },
            required: %w[user]
          },
          login_credentials: {
            type: 'object',
            properties: {
              email: { type: 'string' },
              password: { type: 'string' }
            },
            required: %w[email password]
          },
          login: {
            type: 'object',
            properties: {
              authentication: { '$ref' => '#/components/schemas/login_credentials' }
            }
          },
          login_response: {
            type: 'object',
            properties: {
              message: { type: 'string' },
              token: { type: 'string' }
            },
            required: %w[message token]
          },
          logout_response: {
            type: 'object',
            properties: {
              message: { type: 'string' }
            },
            required: %w[message]
          },
          pagination: {
            type: 'object',
            properties: {
              current_page: { type: 'integer' },
              next_page: { type: 'integer', nullable: true },
              prev_page: { type: 'integer', nullable: true },
              total_pages: { type: 'integer' },
              total_count: { type: 'integer' }
            },
            required: %w[current_page
                         next_page
                         prev_page
                         total_pages
                         total_count]
          },
          error: {
            type: 'object',
            properties: {
              status: { type: 'integer' },
              error: { type: 'string' },
              message: { type: 'string' }
            },
            required: %w[status error message]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
