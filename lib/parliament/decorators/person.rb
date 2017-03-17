module Parliament
  module Decorators
    # Decorator namespace for Grom::Node instances with type: http://id.ukpds.org/schema/Person
    module Person
      # Alias personGivenName with fallback.
      #
      # @return [String, String] the given name of the Grom::Node or an empty string.
      def given_name
        respond_to?(:personGivenName) ? personGivenName : ''
      end

      # Alias personFamilyName with fallback.
      #
      # @return [String, String] the family name of the Grom::Node or an empty string.
      def family_name
        respond_to?(:personFamilyName) ? personFamilyName : ''
      end

      # Alias personOtherNames with fallback.
      #
      # @return [String, String] the other names of the Grom::Node or an empty string.
      def other_name
        respond_to?(:personOtherNames) ? personOtherNames : ''
      end

      # Alias personDateOfBirth with fallback.
      #
      # @return [DateTime, nil] the date of birth of the Grom::Node or nil.
      def date_of_birth
        respond_to?(:personDateOfBirth) ? DateTime.parse(personDateOfBirth) : nil
      end

      # Builds a full name using personGivenName and personFamilyName.
      #
      # @return [String, String] the full name of the Grom::Node or an empty string.
      def full_name
        full_name = ''
        full_name += respond_to?(:personGivenName) ? personGivenName + ' ' : ''
        full_name += respond_to?(:personFamilyName) ? personFamilyName : ''
        full_name.rstrip
      end

      # Alias memberHasIncumbency with fallback.
      #
      # @return [Array, Array] all the incumbencies of the Grom::Node or an empty array.
      def incumbencies
        respond_to?(:memberHasIncumbency) ? memberHasIncumbency : []
      end

      # Alias memberHasIncumbency with fallback.
      #
      # @return [Array, Array] the seat incumbencies of the Grom::Node or an empty array.
      def seat_incumbencies
        if respond_to?(:memberHasIncumbency)
          memberHasIncumbency.select { |inc| inc.type == 'http://id.ukpds.org/schema/SeatIncumbency' }
        else
          []
        end
      end

      # Alias memberHasIncumbency with fallback.
      #
      # @return [Array, Array] the house incumbencies of the Grom::Node or an empty array.
      def house_incumbencies
        if respond_to?(:memberHasIncumbency)
          memberHasIncumbency.select { |inc| inc.type == 'http://id.ukpds.org/schema/HouseIncumbency' }
        else
          []
        end
      end

      # Alias seatIncumbencyHasHouseSeat with fallback.
      #
      # @return [Array, Array] the seats of the Grom::Node or an empty array.
      def seats
        return @seats unless @seats.nil?

        seats = []
        seat_incumbencies.each do |incumbency|
          seats << incumbency.seat if incumbency.respond_to?(:seat)
        end

        @seats = seats.flatten.uniq
      end

      # Alias houseSeatHasHouse with fallback.
      #
      # @return [Array, Array] the houses of the Grom::Node or an empty array.
      def houses
        return @houses unless @houses.nil?

        houses = []
        seats.each do |seat|
          houses << seat.house
        end

        house_incumbencies.each do |inc|
          houses << inc.house
        end

        @houses = houses.flatten.uniq
      end

      # Alias houseSeatHasConstituencyGroup with fallback.
      #
      # @return [Array, Array] the constituencies of the Grom::Node or an empty array.
      def constituencies
        return @constituencies unless @constituencies.nil?

        constituencies = []
        seats.each do |seat|
          constituencies << seat.constituency
        end

        @constituencies = constituencies.flatten.uniq
      end

      # Alias partyMemberHasPartyMembership with fallback.
      #
      # @return [Array, Array] the party memberships of the Grom::Node or an empty array.
      def party_memberships
        respond_to?(:partyMemberHasPartyMembership) ? partyMemberHasPartyMembership : []
      end

      # Alias partyMembershipHasParty with fallback.
      #
      # @return [Array, Array] the parties of the Grom::Node or an empty array.
      def parties
        return @parties unless @parties.nil?

        parties = []
        party_memberships.each do |party_membership|
          parties << party_membership.party
        end

        @parties = parties.flatten.uniq.compact
      end

      # Alias personHasContactPoint with fallback.
      #
      # @return [Array, Array] the contact points of the Grom::Node or an empty array.
      def contact_points
        respond_to?(:personHasContactPoint) ? personHasContactPoint : []
      end

      # Alias personHasGenderIdentity with fallback.
      #
      # @return [Array, Array] the gender identities of the Grom::Node or an empty array.
      def gender_identities
        respond_to?(:personHasGenderIdentity) ? personHasGenderIdentity : []
      end

      # Alias genderIdentityHasGender with fallback.
      #
      # @return [Array, Array] the gender of the Grom::Node or nil.
      def gender
        gender_identities.empty? ? nil : gender_identities.first.gender
      end

      # Checks the statuses of the Grom::Node.
      #
      # @return [Hash, Hash] the statuses of the Grom::Node or an empty hash.
      def statuses
        return @statuses unless @statuses.nil?

        statuses = {}
        statuses[:house_membership_status] = house_membership_status
        statuses[:general_membership_status] = general_membership_status

        @statuses = statuses
      end

      # Alias D79B0BAC513C4A9A87C9D5AFF1FC632F with fallback.
      #
      # @return [String, String] the full title of the Grom::Node or an empty string.
      def full_title
        respond_to?(:D79B0BAC513C4A9A87C9D5AFF1FC632F) ? self.D79B0BAC513C4A9A87C9D5AFF1FC632F : ''
      end

      # Alias F31CBD81AD8343898B49DC65743F0BDF with fallback.
      #
      # @return [String, String] the display name of the Grom::Node or the full name.
      def display_name
        respond_to?(:F31CBD81AD8343898B49DC65743F0BDF) ? self.F31CBD81AD8343898B49DC65743F0BDF : full_name
      end

      # Alias A5EE13ABE03C4D3A8F1A274F57097B6C with fallback.
      #
      # @return [String, String] the sort name of the Grom::Node or an empty string.
      def sort_name
        respond_to?(:A5EE13ABE03C4D3A8F1A274F57097B6C) ? self.A5EE13ABE03C4D3A8F1A274F57097B6C : ''
      end

      private

      def house_membership_status
        statuses = []
        statuses << 'Current MP' unless seat_incumbencies.select(&:current?).empty?
        statuses << 'Lord' unless house_incumbencies.select(&:current?).empty?
        statuses << 'Former Lord' if !house_incumbencies.empty? && house_incumbencies.select(&:current?).empty?
        statuses << 'Former MP' if !seat_incumbencies.empty? && seat_incumbencies.select(&:current?).empty?
        statuses
      end

      def general_membership_status
        statuses = []
        statuses << 'Current Member' unless incumbencies.select(&:current?).empty?
        statuses << 'Former Member' if !incumbencies.empty? && incumbencies.select(&:current?).empty?
        statuses
      end
    end
  end
end
