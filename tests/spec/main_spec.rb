describe 'database' do
    def run_script(commands)
        raw_output = nil
        IO.popen("./../easydb", "r+") do |pipe|
            commands.each do |command|
                pipe.puts command
            end

            pipe.close_write

            raw_output = pipe.gets(nil)
        end
        raw_output.split("\n")
    end

    it 'inserts and retrieves a row' do
        result = run_script([
            "insert 1 user1 person1@easydb.com",
            "select",
            ".exit",
        ])
        expect(result).to match_array([
            "db > Executed.",
            "db > (1, user1, person1@easydb.com)",
            "Executed.",
            "db > Exiting...",
        ])
    end

    it 'prints error message when table is full' do
        script = (1..1401).map do |i|
            "insert #{i} user#{i} person#{i}@easydb.com"
        end
        script << ".exit"
        result = run_script(script)
        expect(result[-2]).to eq("db > Error: Table full.")
    end

    it 'allows inserting strings that are maximum length' do
        long_username = "a"*32
        long_email = "a"*255
        script = [
            "insert 1 #{long_username} #{long_email}",
            "select",
            ".exit",
        ]
        result = run_script(script)
        expect(result).to match_array([
            "db > Executed.",
            "db > (1, #{long_username}, #{long_email})",
            "Executed.",
            "db > Exiting...",
        ])
    end

    it 'prints error message if strings are too long' do
        long_username = "a"*33
        long_email = "a"*256
        script = [
            "insert 1 #{long_username} #{long_email}",
            "select",
            ".exit",
        ]
        result = run_script(script)
        expect(result).to match_array([
            "db > String is too long.",
            "db > Executed.",
            "db > Exiting...",
        ])
    end

    it 'prints an error message if id is negative' do
        script = [
            "insert -1 william8th will@easydb.com",
            "select",
            ".exit",
        ]
        result = run_script(script)
        expect(result).to match_array([
            "db > ID must be positive.",
            "db > Executed.",
            "db > Exiting...",
        ])
    end

end
