require 'spec_helper'

RSpec.describe PublishRetirementEventWorker do
  let(:worker) { described_class.new }
  let(:workflow) { create(:workflow) }
  let(:payload_expectation) do
    a_hash_including(
      project_id: workflow.project_id,
      workflow_id: workflow.id,
      subjects_count: workflow.subjects_count,
      retired_subjects_count: workflow.retired_subjects_count,
      classifications_count: workflow.classifications_count
    )
  end

  describe "#perform" do
    it "should gracefully handle a missing workflow lookup" do
      expect{
        worker.perform(-1)
      }.not_to raise_error
    end

    it "should publish via EventStream" do
      expect(EventStream).to receive(:push)
        .with("workflow_counters", payload_expectation)
      worker.perform(workflow.id)
    end

    it "should publish via EventStream" do
      expect(KinesisPublisher).to receive(:publish)
        .with("workflow_counters", workflow.id, payload_expectation)
      worker.perform(workflow.id)
    end
  end
end
