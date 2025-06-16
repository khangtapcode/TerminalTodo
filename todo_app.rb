# terminal_todo.rb

# --- 1. SETUP ---
# Tell Ruby to load the libraries we need.
require 'tty-prompt'
require 'pastel'
require 'time'

# Create instances of the tools we'll use.
prompt = TTY::Prompt.new(active_color: :cyan)
pastel = Pastel.new

# --- 2. APPLICATION STATE ---
# This array holds all our tasks.
tasks = [
  { description: "Package this app into a single file", status: :pending },
  { description: "Share it with a friend", status: :pending },
]

# This holds the start time for our stopwatch, or `nil` if it's off.
stopwatch_start_time = nil

# --- 3. HELPER METHODS ---
# These methods keep our main loop clean and readable.

def display_tasks(task_list, pastel_instance)
  puts pastel_instance.bold.yellow("📋 TASKS:")
  if task_list.empty?
    puts "  No tasks yet. Add one!"
  else
    task_list.each_with_index do |task, index|
      if task[:status] == :done
        puts "  #{index + 1}. #{pastel_instance.green.strikethrough(task[:description])}"
      else
        puts "  #{index + 1}. #{task[:description]}"
      end
    end
  end
end

def display_stopwatch(start_time, pastel_instance)
  puts pastel_instance.bold.yellow("⏱️  STOPWATCH:")
  if start_time
    elapsed_seconds = (Time.now - start_time).to_i
    puts "  Running for #{elapsed_seconds} seconds..."
  else
    puts "  Not running."
  end
end

# --- 4. MAIN APPLICATION LOOP ---
loop do
  # Clear the terminal screen on each iteration.
  system "clear" or system "cls"

  # Display the app header.
  puts pastel.bold.cyan("╔══════════════════════════════════════╗")
  puts pastel.bold.cyan("║            TerminalTodo            ║")
  puts pastel.bold.cyan("╚══════════════════════════════════════╝")
  puts "" # Spacing

  # Display the current state of the UI.
  display_tasks(tasks, pastel)
  puts ""
  display_stopwatch(stopwatch_start_time, pastel)
  puts ""

  # --- Build the User Menu ---
  menu_choices = [
    { name: '✅ Add a new task', value: :add },
  ]
  
  unless tasks.empty?
    menu_choices << { name: '💅 Toggle task status (done/pending)', value: :toggle }
    menu_choices << { name: '❌ Delete a task', value: :delete }
  end

  if stopwatch_start_time
    menu_choices << { name: '⏹️  Stop the Stopwatch', value: :stop_sw }
  else
    menu_choices << { name: '▶️  Start the Stopwatch', value: :start_sw }
  end

  menu_choices << { name: '🚪 Exit', value: :exit }

  # --- Get User Input ---
  user_action = prompt.select("What do you want to do?", menu_choices)

  # --- 5. HANDLE USER ACTION ---
  case user_action
  when :add
    new_task_desc = prompt.ask("Enter the description for the new task:")
    tasks << { description: new_task_desc, status: :pending } if new_task_desc

  when :toggle
    task_descriptions = tasks.map { |t| t[:description] }
    task_to_toggle = prompt.select("Which task do you want to toggle?", task_descriptions)
    tasks.find { |t| t[:description] == task_to_toggle }&.tap { |t| t[:status] = (t[:status] == :pending ? :done : :pending) }
    
  when :delete
    task_descriptions = tasks.map { |t| t[:description] }
    task_to_delete = prompt.select("Which task do you want to DELETE?", task_descriptions, active_color: :red)
    tasks.reject! { |t| t[:description] == task_to_delete }

  when :start_sw
    stopwatch_start_time = Time.now
    prompt.ok("Stopwatch started!")
    sleep(1)

  when :stop_sw
    elapsed_seconds = (Time.now - stopwatch_start_time).round(2)
    stopwatch_start_time = nil
    prompt.ok("Stopwatch stopped! Elapsed time: #{elapsed_seconds} seconds.")
    prompt.keypress("Press any key to continue...")

  when :exit
    puts pastel.bold("Goodbye!")
    break
  end
end