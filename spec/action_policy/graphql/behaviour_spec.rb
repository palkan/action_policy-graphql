# frozen_string_literal: true

require "spec_helper"

describe ActionPolicy::GraphQL::Behaviour do
  include_context "common:graphql"

  let(:user) { :user }
  let(:post) { Post.new("private") }

  let(:schema) { Schema }
  let(:context) { {current_user: user} }

  describe ".authorized? + allowed_to?" do
    let(:query) do
      %({
        authorizedPost {
          title
        }
      })
    end

    before { allow(Schema).to receive(:post) { post } }

    specify do
      expect(data).to be_nil
    end

    context "when admin" do
      let(:user) { :admin }

      specify do
        expect(data.fetch("title")).to eq "private"
      end
    end

    context "namespaced" do
      let(:post) { Post.new("namespaced") }

      let(:query) do
        %({
          authorizedNamespacedPost {
            title
          }
        })
      end

      specify do
        expect(data.fetch("title")).to eq "namespaced"
      end

      context "mutation" do
        let(:query) do
          %(mutation {
            adminCreatePost(title: "GQL") {
              post {
                title
              }
            }
          })
        end

        it "is authorized" do
          expect { subject }.to be_authorized_to(:create?, Post)
            .with(MyNamespace::PostPolicy)
        end
      end

      context "authorized mutation" do
        let(:query) do
          %(mutation {
            adminCreatePostAuthorized(title: "GQL") {
              post {
                title
              }
            }
          })
        end

        it "is authorized" do
          expect { subject }.to be_authorized_to(:create?, Post)
            .with(MyNamespace::PostPolicy)
        end
      end
    end
  end
end
