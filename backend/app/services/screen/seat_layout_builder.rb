class Screen
  # Builds a standard seat grid based on `screen.rows` x `screen.columns`,
  # with optional override layout describing category & pricing per row range.
  #
  # layout: [
  #   { rows: "A-B", category: "premium",  price: 15.0 },
  #   { rows: "C-G", category: "standard", price: 10.0 }
  # ]
  class SeatLayoutBuilder
    DEFAULT_LAYOUT = ->(s) {
      [{ rows: "A-#{('A'.ord + s.rows - 1).chr}", category: 'standard', price: 8.99 }]
    }

    def initialize(screen, layout: nil)
      @screen = screen
      @layout = layout.presence || DEFAULT_LAYOUT.call(screen)
    end

    def build!
      Seat.transaction do
        @screen.seats.delete_all
        rows_payload = []

        @layout.each do |segment|
          range_rows = expand_rows(segment['rows'] || segment[:rows])
          category   = segment['category'] || segment[:category] || 'standard'
          price      = (segment['price'] || segment[:price]).to_f

          range_rows.each do |row_label|
            (1..@screen.columns).each do |col|
              rows_payload << {
                id:           SecureRandom.uuid,
                screen_id:    @screen.id,
                row_label:    row_label,
                column_index: col,
                category:     category,
                base_price:   price,
                created_at:   Time.current,
                updated_at:   Time.current
              }
            end
          end
        end

        Seat.insert_all!(rows_payload)
      end
    end

    private

    def expand_rows(spec)
      from, to = spec.to_s.split('-').map { |c| c.strip.upcase }
      return [from] if to.nil?

      (from..to).to_a
    end
  end
end
