module Texas
  module Build
    module Task
      class PublishPDF < Base
        DEFAULT_TEX_COMMAND = "pdflatex"

        def cmd
          @cmd ||= scripts && scripts['tex']
        end

        def scripts
          build.config['script']
        end

        def master_file
          build.master_file
        end

        def build_path
          build.__path__
        end

        def dest_file
          build.dest_file
        end

        def run
          run_tex
          copy_pdf_file_to_dest_dir
        end

        def copy_pdf_file_to_dest_dir
          tmp_file = File.join(build_path, "#{File.basename(master_file, '.tex')}.pdf")
          FileUtils.mkdir_p File.dirname(dest_file)
          FileUtils.copy tmp_file, dest_file
          verbose {
            file = File.join(build_path, "master.log")
            output = `grep "Output written on" #{file}`
            @page_count = output[/(\d+?) pages?/, 1]
            "Written PDF in #{dest_file.gsub(build.root, '')} (#{@page_count} pages)".green
          }
        end

        def run_tex
          if process_tex_cmd
            verbose { "Running #{process_tex_cmd} in #{build_path} ..." }
            Dir.chdir build_path do
              2.times do
                `#{process_tex_cmd} #{File.basename(master_file)}`
              end
            end
          else
            puts "Can't publish PDF: no default command recognized. Specify in #{Build::Base::CONFIG_FILE}"
          end
        end

        def process_tex_cmd
          cmd || begin
            default = `which #{DEFAULT_TEX_COMMAND}`.strip
            default.empty? ? nil : default
          end
        end

      end
    end
  end
end
