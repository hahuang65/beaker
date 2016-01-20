Bureaucrat.start(default_path: './API_doc.md')
ExUnit.start(formatters: [ExUnit.CLIFormatter, Bureaucrat.Formatter])
TestApp.start_link()
