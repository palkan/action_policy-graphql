# frozen_string_literal: true

require "spec_helper"

describe "#expose_authorization_rules", :aggregate_failures do
  include_context "common:graphql"

  let(:post) { Post.new("private") }

  let(:schema) { Schema }
  let(:query) do
    %({
        post {
          title
          canShow {
            value
            message
            reasons {
              details
              fullMessages
            }
          }
          canEdit {
            value
            message
            reasons {
              details
              fullMessages
            }
          }
          can_i_destroy {
            value
            message
            reasons {
              details
              fullMessages
            }
          }
        }
      })
  end

  before { allow(Schema).to receive(:post) { post } }

  context "when failure" do
    specify do
      expect(data.fetch("canShow").fetch("value")).to eq false
      expect(data.fetch("canShow").fetch("message")).to eq "Cannot show post"

      expect(data.fetch("canEdit").fetch("value")).to eq false
      expect(data.fetch("canEdit").fetch("message")).to eq "You shall not do this"

      expect(data.fetch("can_i_destroy").fetch("value")).to eq false
      expect(data.fetch("can_i_destroy").fetch("message")).to eq "You shall not do this"
    end

    specify "#reasons" do
      reasons = data.fetch("can_i_destroy").fetch("reasons")

      expect(reasons.fetch("details")).to eq(
        {post: [:public?]}.to_json
      )
      expect(reasons.fetch("fullMessages")).to eq(
        [
          "Post is not public"
        ]
      )
    end
  end

  context "when success" do
    let(:post) { Post.new("public-visible") }

    specify do
      expect(data.fetch("canShow").fetch("value")).to eq true
      expect(data.fetch("canShow").fetch("message")).to be_nil
      expect(data.fetch("canShow").fetch("reasons")).to be_nil

      expect(data.fetch("can_i_destroy").fetch("value")).to eq true
      expect(data.fetch("can_i_destroy").fetch("message")).to be_nil
      expect(data.fetch("can_i_destroy").fetch("reasons")).to be_nil
    end
  end

  context "namespaced" do
    let(:query) do
      %({
          me {
            allPosts {
              title
              canShow {
                value
                message
                reasons {
                  details
                  fullMessages
                }
              }
            }
          }
        })
    end

    let(:field) { "me->allPosts" }

    before do
      allow(Me).to receive(:posts) { [post] }
    end

    context "when failure" do
      let(:post) { Post.new("not mine") }

      specify do
        expect(data.first.fetch("canShow").fetch("value")).to eq false
        expect(data.first.fetch("canShow").fetch("message")).to eq "Cannot show post"
      end
    end

    context "when success" do
      let(:post) { Post.new("story of my life") }

      specify do
        expect(data.first.fetch("canShow").fetch("value")).to eq true
        expect(data.first.fetch("canShow").fetch("message")).to be_nil
        expect(data.first.fetch("canShow").fetch("reasons")).to be_nil
      end
    end
  end

  context "with field_name" do
    let(:query) do
      %({
        me {
          canCreatePost {
            value
            message
            reasons {
              details
              fullMessages
            }
          }
        }
      })
    end

    let(:field) { "me" }

    specify do
      expect(data.fetch("canCreatePost").fetch("value")).to eq true
      expect(data.fetch("canCreatePost").fetch("message")).to be_nil
      expect(data.fetch("canCreatePost").fetch("reasons")).to be_nil
    end
  end
end
