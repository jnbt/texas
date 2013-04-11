module Texas
  module Task
    module Tests
      class PlenkedFootnotes < Task::Test
        def run
          if plenked_footnotes.empty?
            ok "Footnotes at end of sentence"
          else
            fail "Footnotes at end of sentence" do
              filenames_and_excerpts.each do |(template, excerpt)|
                puts "#" + " " + template.gsub(build.root, '').cyan
                puts "#" + "   #{excerpt}"
              end
            end
          end
        end

        def plenked_footnotes
          @plenked_footnotes ||= `grep -iR "\. <%= f" #{Texas.contents_subdir_name}/`
        end

        def filenames_and_excerpts
          plenked_footnotes.lines.map { |l| l.scan(/(.+?)\:(.+)/).first }
        end
      end
    end
  end
end
