class Keepr::GroupsCreator
  def initialize(target)
    @target = target
  end

  def run
    case @target
    when 'Balance' then
      load 'asset.txt', :target => 'Asset'
      load 'liability.txt', :target => 'Liability'
    when 'Profit & Loss'
      load 'profit_and_loss.txt', :target => 'Profit & Loss'
    else
      raise ArgumentError
    end
  end

private
  def load(filename, options)
    full_filename = File.join(__dir__, "groups_creator/#{filename}".downcase)
    lines = File.readlines(full_filename)
    last_depth = 0
    parents = []

    lines.each do |line|
      depth = line[/\A */].size / 2
      attributes = options.merge(:name => line.strip)

      if depth == 0
        parents = []
        group = Keepr::Group.create!(attributes)
      else
        parents.pop if depth <= last_depth
        parents.pop if depth < last_depth
        group = parents.last.children.create!(attributes)
      end
      parents.push(group)

      last_depth = depth
    end
  end
end
