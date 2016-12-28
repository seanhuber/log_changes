module LogChanges
  describe Base do
    before :each do
      Dir.glob(Rails.root.join('log', 'record_changes', '*.log')) do |filename|
        File.open(filename, 'w') {|file| file.truncate(0)}
      end
    end

    it 'should create a dedicated log file' do
      logfile_path = Rails.root.join 'log', 'record_changes', "#{Date.today.strftime '%Y.%m'}_Employee.log"
      FactoryGirl.create :employee
      expect(File).to exist(logfile_path)
      expect(File.readlines(logfile_path).any?).to be true
    end

    it 'should log creations to a log file' do
      logfile_path = Rails.root.join 'log', 'record_changes', "#{Date.today.strftime '%Y.%m'}_Employee.log"
      FactoryGirl.create :employee
      log_lines = File.readlines(logfile_path).map(&:strip)
      expect(log_lines).to include('first_name: Jane')
      expect(log_lines).to include('last_name: Doe')
      first_msg = log_lines.select{|str| str.include?('New Employee') && str.include?('Jane Doe')}
      expect(first_msg.any?).to be true
    end

    it 'should create separate log files for separate models' do
      employee = FactoryGirl.create :employee
      product  = FactoryGirl.create :product, employee: employee
      picture  = FactoryGirl.create :picture, imageable: product

      ['Employee', 'Product', 'Picture'].each do |model|
        logfile_path = Rails.root.join 'log', 'record_changes', "#{Date.today.strftime '%Y.%m'}_#{model}.log"
        expect(File).to exist(logfile_path)
        expect(File.readlines(logfile_path).any?).to be true
      end

      # employee.update_attributes! last_name: 'Smith'
      # puts "\n\nEmployee count: #{Employee.count}\nProduct count: #{Product.count}\nPicture count: #{Picture.count}\n\n"
      # expect(true).to be true
    end
  end
end
