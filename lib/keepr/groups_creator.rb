# frozen_string_literal: true

class Keepr::GroupsCreator
  def initialize(target, language)
    raise ArgumentError unless %i[balance profit_and_loss].include?(target)
    raise ArgumentError unless %i[de es en].include?(language)

    @target   = target
    @language = language
  end

  def run
    case @target
    when :balance then
      load 'asset.txt', target: :asset
      load 'liability.txt', target: :liability
    when :profit_and_loss
      load 'profit_and_loss.txt', target: :profit_and_loss
    end
  end

  private

  def load(filename, options)
    full_filename = File.join(File.dirname(__FILE__), "groups_creator/#{@language.to_s}/#{filename}".downcase)
    lines = File.readlines(full_filename)
    last_depth = 0
    parents = []

    lines.each do |line|
      # Count leading spaces to calc hierarchy depth
      depth = line[/\A */].size / 2

      # Remove leading spaces and separate number and name
      number, name = line.lstrip.match(/^(.*?)\s(.+)$/).to_a[1..-1]

      attributes = options.merge(name: name, number: number)
      attributes[:is_result] = true if @target == :balance && name == annual_surplus

      if depth.zero?
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

  def annual_surplus
    case @language
    when :en
      return 'Annual surplus / annual deficit'
    when :es
      return 'Superávit anual / déficit anual'
    when :de
      return 'Jahresüberschuss/Jahresfehlbetrag'
    end
  end
end
