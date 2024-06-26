# frozen_string_literal: true

RSpec.describe "bundle update" do
  let(:config) {}

  before do
    gemfile <<-G
      source "https://gem.repo1"
      gem 'myrack', "< 1.0"
      gem 'thin'
    G

    bundle "config set #{config}" if config

    bundle :install
  end

  shared_examples "a config observer" do
    context "when ignore post-install messages for gem is set" do
      let(:config) { "ignore_messages.myrack true" }

      it "doesn't display gem's post-install message" do
        expect(out).not_to include("Myrack's post install message")
      end
    end

    context "when ignore post-install messages for all gems" do
      let(:config) { "ignore_messages true" }

      it "doesn't display any post-install messages" do
        expect(out).not_to include("Post-install message")
      end
    end
  end

  shared_examples "a post-install message outputter" do
    it "should display post-install messages for updated gems" do
      expect(out).to include("Post-install message from myrack:")
      expect(out).to include("Myrack's post install message")
    end

    it "should not display the post-install message for non-updated gems" do
      expect(out).not_to include("Thin's post install message")
    end
  end

  context "when listed gem is updated" do
    before do
      gemfile <<-G
        source "https://gem.repo1"
        gem 'myrack'
        gem 'thin'
      G

      bundle :update, all: true
    end

    it_behaves_like "a post-install message outputter"
    it_behaves_like "a config observer"
  end

  context "when dependency triggers update" do
    before do
      gemfile <<-G
        source "https://gem.repo1"
        gem 'myrack-obama'
        gem 'thin'
      G

      bundle :update, all: true
    end

    it_behaves_like "a post-install message outputter"
    it_behaves_like "a config observer"
  end
end
