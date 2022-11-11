require_relative './tictac.rb'

describe Square do

  subject(:square_selected) { described_class.new(5,true) }  
  subject(:square_not_selected) { described_class.new(3) }
  
  describe 'select_square' do
    it 'returns a truthy value for @selected' do
      expect(square_selected.selected).to be_truthy
    end

    it 'raises an exception when selecting a square that is already selected' do
      expect { square_selected.select_square(1) }.to raise_error("This square is already selected")
    end

    
    it 'changes @marker to "X" when Player 1 is active player' do 
      active_player = 1
      expect { square_not_selected.select_square(active_player) }.to change { square_not_selected.marker }.to("[X]")
    end

    it 'changes @marker to "O" when Player 2 is active player' do
      active_player = 2
      expect { square_not_selected.select_square(active_player) }.to change { square_not_selected.marker }.to("[O]")
    end
  end
end
      