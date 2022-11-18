module Joinor
  def joinor(to_join, delimiter: ', ', final: 'or')
    case to_join.length
    when 0 then ''
    when 1 then to_join[0]
    when 2 then to_join.join(" #{final} ")
    else
      to_join[0..-2].join(delimiter) + delimiter +
        final + ' ' + to_join[-1].to_s
    end
  end
end

class Deck
  def initialize
    reset
  end

  def reset
    @cards = []
    Card::SUITS.each do |suit|
      Card::RANKS.each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def draw_card
    @cards.pop
  end
end

class Card
  SUITS = [:hearts, :diamonds, :spades, :clubs]
  RANKS = [:two, :three, :four, :five, :six, :seven, :eight, :nine, :ten,
           :jack, :queen, :king, :ace]
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{@rank} of #{@suit}"
  end

  def value
    VALUES[RANKS.find_index(@rank)]
  end

  def ace?
    @rank == :ace
  end
end

class Player
  attr_reader :name

  include Joinor

  def initialize
    @hand = []
  end

  def <<(card)
    @hand << card
  end

  def reveal_cards
    "#{joinor(@hand, final: 'and')}. Total: #{total}"
  end

  def reveal_one_card
    "#{@hand[0]} and unknown card."
  end

  def last
    @hand.last
  end

  def total
    initial_total = @hand.map(&:value).sum
    if initial_total > 21
      number_of_aces.times do
        initial_total -= 10
        break if initial_total < 22
      end
    end
    initial_total
  end

  def bust?
    total > 21
  end

  def empty_hand
    @hand = []
  end

  private

  def number_of_aces
    @hand.count(&:ace?)
  end
end
