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
    end

    it 'should log updates' do
      employee = FactoryGirl.create :employee
      logfile_path = Rails.root.join 'log', 'record_changes', "#{Date.today.strftime '%Y.%m'}_Employee.log"
      File.open(logfile_path, 'w') {|file| file.truncate(0)}
      employee.update_attributes! first_name: 'John', last_name: 'Smith'
      log_lines = File.readlines(logfile_path).map(&:strip)
      first_msg = log_lines.select{|str| str.include?('Updated Employee') && str.include?('John Smith')}
      expect(first_msg.any?).to be true
      [
        'first_name:',
        'FROM: Jane',
        'TO: John',
        'last_name:',
        'FROM: Doe',
        'TO: Smith'
      ].each do |log_line|
        expect(log_lines).to include(log_line)
      end
    end
  end
end
