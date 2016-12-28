module LogChanges
  describe Base do
    before :each do
      FileUtils.rm_rf(Rails.root.join('log', 'record_changes')) if File.directory? Rails.root.join('log', 'record_changes')
    end

    it 'should assert the truth' do
      FactoryGirl.create :my_model
      puts "\n\n#{MyModel.count}\n\n"
      expect(true).to be true
    end
  end
end
