module Orias
  # Dedicated to Orias intermediaries objects handling
  #
  class Intermediary < Base
    attr_accessor :raw, :found, :siren, :orias, :denomination, :registrations

    alias_method :registration_number, :orias

    # Initialize an Orias::Intermediary instance
    def initialize(attributes = {})
      @raw = attributes

      base = @raw.dig('informationBase')

      @found = base.dig('foundInRegistry') == 'true'
      @siren = base.dig('siren')
      @orias = base.dig('registrationNumber')
      @denomination = base.dig('denomination')

      raw_registrations = @raw.dig('registrations', 'registration')
      unless raw_registrations.is_a?(Array)
        raw_registrations = [raw_registrations]
      end

      @registrations = raw_registrations.compact.map do |h|
        Orias::Registration.new(h)
      end
    end

    def subscribed
      !registrations_with_status('INSCRIT').empty?
    end

    # Registrations collections

    def registrations_with_status(status_value)
      @registrations.select do |registration|
        registration.status == status_value
      end
    end

    private

    class << self
    end
  end
end
