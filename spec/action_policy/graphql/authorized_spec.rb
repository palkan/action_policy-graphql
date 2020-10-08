# frozen_string_literal: true

require "spec_helper"

describe "field extensions", :aggregate_failures do
  include_context "common:graphql"

  let(:user) { :user }

  let(:schema) { Schema }
  let(:context) { {user: user} }

  context "authorized_scope: *" do
    let(:posts) { [Post.new("private-a"), Post.new("public-b")] }
    let(:query) do
      %({
          posts {
            title
          }
        })
    end

    before do
      allow(Schema).to receive(:posts) { PostList.new(posts) }
    end

    it "has authorized scope" do
      expect { subject }.to have_authorized_scope(:data)
        .with(PostPolicy)
    end

    specify "as user" do
      expect(data.size).to eq 1
      expect(data.first.fetch("title")).to eq "public-b"
    end

    context "as admin" do
      let(:user) { :admin }

      specify do
        expect(data.size).to eq 2
        expect(data.map { |v| v.fetch("title") }).to match_array(
          [
            "private-a",
            "public-b"
          ]
        )
      end
    end

    context "namespaced" do
      let(:posts) { [Post.new("not mine"), Post.new("story of my life")] }
      let(:query) do
        %({
            me {
              posts {
                title
              }
            }
          })
      end

      before do
        allow(Me).to receive(:posts) { PostList.new(posts) }
      end

      it "has authorized scope" do
        expect { subject }.to have_authorized_scope(:data)
          .with(Me::PostPolicy)
      end
    end

    context "connections" do
      let(:query) do
        %({
          connectedPosts(first: 1) {
            nodes {
              title
            }
          }
        })
      end

      it "has authorized scope" do
        expect { subject }.to have_authorized_scope(:data)
          .with(PostPolicy)
      end

      context "with connection: true" do
        let(:query) do
          %({
            anotherConnectedPosts(first: 1) {
              totalCount
              nodes {
                title
              }
            }
          })
        end

        it "has authorized scope" do
          expect { subject }.to have_authorized_scope(:data)
            .with(PostPolicy)
        end

        specify do
          expect(data["totalCount"]).to eq 1
          expect(data["nodes"][0]["title"]).to eq "public-b"
        end
      end
    end
  end

  context "authorize: *" do
    let(:post) { Post.new("private-a") }
    let(:query) do
      %({
          authPost {
            title
          }
        })
    end

    before do
      allow(Schema).to receive(:post) { post }
    end

    it "is authorized" do
      expect { subject }.to be_authorized_to(:show?, post)
        .with(PostPolicy)
    end

    specify "as user" do
      expect { subject }.to raise_error(ActionPolicy::Unauthorized)
    end

    context "accessible resource" do
      let(:post) { Post.new("post-c-visible") }

      specify do
        expect(data.fetch("title")).to eq "post-c-visible"
      end
    end

    context "as admin" do
      let(:user) { :admin }

      specify do
        expect(data.fetch("title")).to eq "private-a"
      end
    end

    context "with options" do
      let(:query) do
        %({
            anotherPost {
              title
            }
          })
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:preview?, post)
          .with(AnotherPostPolicy)
      end
    end

    context "non-raising authorize" do
      let(:query) do
        %({
            nonRaisingPost {
              title
            }
          })
      end

      it "returns nil" do
        expect(data).to be_nil
      end
    end

    context "namespaced" do
      let(:query) do
        %({
            me {
              bio {
                title
              }
            }
          })
      end

      before do
        allow(Me).to receive(:post) { post }
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:show?, post)
          .with(Me::PostPolicy)
      end
    end

    context "with resolver" do
      let(:query) do
        %({
            resolvedPost {
              title
            }
          })
      end

      before do
        allow(Me).to receive(:post) { post }
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:show?, post)
          .with(PostPolicy)
      end
    end

    context "with mutation" do
      let(:query) do
        %(mutation {
          createPost(title: "GQL") {
            post {
              title
            }
          }
        })
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:publish?, anything)
          .with(PostPolicy)
      end

      # See spec_helper.rb for default settings
      it "raises if authorize_raise_exception is set to true" do
        expect { subject }.to raise_error(ActionPolicy::Unauthorized)
      end
    end
  end

  context "preauthorize: *" do
    context "collection" do
      let(:posts) { [Post.new("private-a"), Post.new("public-b")] }
      let(:query) do
        %({
            secretPosts {
              title
            }
          })
      end

      before do
        allow(Schema).to receive(:posts) { PostList.new(posts) }
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:view_secret_posts?, "secretPosts")
          .with(PostPolicy)
      end

      specify "as user" do
        expect { subject }.to raise_error(ActionPolicy::Unauthorized)
      end

      context "as admin" do
        let(:user) { :admin }

        specify do
          expect(data.size).to eq 2
        end
      end

      context "with default collection rule" do
        let(:query) do
          %({
              allPosts {
                title
              }
            })
        end

        it "is authorized" do
          expect { subject }.to be_authorized_to(:index?, "allPosts")
            .with(PostPolicy)
        end
      end
    end

    context "field" do
      let(:post) { Post.new("private-a") }
      let(:query) do
        %({
            secretPost {
              title
            }
          })
      end

      before do
        allow(Schema).to receive(:post) { post }
      end

      it "doesn't resolve field if auth failed" do
        expect(data).to be_nil
        expect(Schema).to_not have_received(:post)
      end

      context "as admin" do
        let(:user) { :admin }

        specify do
          expect(data.fetch("title")).to eq(post.title)
          expect(Schema).to have_received(:post)
        end
      end
    end
  end

  context "authorize_field: *" do
    let(:post) { Post.new("title") }
    let(:query) do
      %({
          post {
            secretTitle
          }
        })
    end

    before do
      allow(post).to receive(:title).and_call_original
      allow(Schema).to receive(:post) { post }
    end

    it "is authorized with object policy" do
      expect { subject }.to be_authorized_to(:secret_title?, post)
        .with(PostPolicy)
    end

    it "doesn't resolve field if auth failed" do
      expect { subject }.to raise_error(ActionPolicy::Unauthorized)
      expect(post).to_not have_received(:title)
    end

    context "as admin" do
      let(:user) { :admin }

      specify do
        expect(data.fetch("secretTitle")).to eq("Secret #{post.title}")
      end
    end

    context "non-raising authorize" do
      let(:query) do
        %({
            post {
              silentSecretTitle
            }
          })
      end

      it "returns nil" do
        expect(data.fetch("silentSecretTitle")).to be_nil
        expect(post).to_not have_received(:title)
      end

      context "as admin" do
        let(:user) { :admin }

        specify do
          expect(data.fetch("silentSecretTitle")).to eq("Secret #{post.title}")
        end
      end
    end

    context "with options" do
      let(:query) do
        %({
            post {
              anotherSecretTitle
            }
          })
      end

      it "is authorized" do
        expect { subject }.to be_authorized_to(:preview?, post)
          .with(AnotherPostPolicy)
      end
    end
  end
end
