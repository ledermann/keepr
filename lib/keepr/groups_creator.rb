class Keepr::GroupsCreator
  def initialize(target)
    @target = target
  end

  def run
    case @target
    when 'Balance' then
      load 'asset.txt', :target => :asset
      load 'liability.txt', :target => :liability
    when 'Profit & Loss'
      load 'profit_and_loss.txt', :target => :profit_and_loss
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
      # Count leading spaces to calc hierarchy depth
      depth = line[/\A */].size / 2

      # Remove leading spaces and separate number and name
      number, name = line.lstrip.match(/^(.*?)\s(.+)$/).to_a[1..-1]

      attributes = options.merge(:name => name, :number => number)
      if @target == 'Balance' && name == 'Jahresüberschuss/Jahresfehlbetrag'
        attributes[:is_result] = true
      end

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
