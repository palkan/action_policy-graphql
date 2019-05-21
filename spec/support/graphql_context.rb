# frozen_string_literal: true

shared_context "common:graphql" do
  let(:context) { {} }
  let(:variables) { {} }
  let(:field) { result.fetch("data").keys.first }
  let(:schema) { raise NotImplementedError.new("Specify schema under test, e.g. `let(:schema) { MySchema }`") }

  let(:data) do
    raise "API Query failed:\n\tquery: #{query}\n\terrors: #{result["errors"]}" if result.key?("errors")
    result.fetch("data").dig(*field.split("->"))
  end

  let(:errors) { result["errors"]&.map { |err| err["message"] } }

  # for connection responses
  let(:edges) { data.fetch("edges").map { |node| node.fetch("node") } }
  let(:page_info) { data.fetch("pageInfo") }

  subject(:result) do
    schema.execute(
      query,
      context: context,
      variables: variables
    )
  end
end
