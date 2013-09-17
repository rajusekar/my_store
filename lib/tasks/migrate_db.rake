namespace :db do
  namespace :migrate_db_to_new_spree do   

    task all: :environment do

#MIGRATING PROMOTIONS
puts "migrating promotions"
truncate_table("spree_activators")
        ActiveRecord::Base.connection.execute("INSERT INTO spree_activators(id, code, description, usage_limit,  created_at, updated_at, expires_at, starts_at, type, match_policy) select  id, code, description, usage_limit, created_at, updated_at, expires_at, starts_at, 'Spree::Promotion', 'all' from #{Settings.old_db.name}.coupons")
      truncate_table("spree_promotion_actions")
        ActiveRecord::Base.connection.execute("INSERT INTO spree_promotion_actions(activator_id,type) select id, 'Spree::Promotion::Actions::CreateAdjustment' from #{Settings.old_db.name}.coupons")
	 ActiveRecord::Base.connection.execute("delete  from spree_calculators where calculable_type = 'Spree::PromotionAction'") 
          ActiveRecord::Base.connection.execute("delete from spree_preferences where `key` like 'spree/calculator%'")
	  Spree::PromotionAction.all.each do |promotion_action|
            old_type = old_db.query("SELECT id, type from calculators WHERE calculable_type='Coupon' AND calculable_id=#{promotion_action.activator_id}", as: :hash)
            calc = promotion_action.build_calculator
	    calc_type = old_type.first["type"]
	    calc_type = "Spree::Calculator::PriceSack" if old_type.first["type"] == "Calculator::PriceBucket"
	    calc.save

	    old_preference = old_db.query("SELECT attribute, value from preferences WHERE owner_type='Calculator' AND owner_id=#{old_type.first["id"]}", as: :hash)
	    if calc_type == "Spree::Calculator::PriceSack" 
	      calc.set_preference(:minimal_amount,0.0 )
              calc.set_preference(:normal_amount,0.0 )
              calc.set_preference(:discount_amount,old_preference.first["value"] )            
            else
	       name = calc_type.split("::").last.underscore
	       calc.set_preference(name.to_sym,old_preference.first["value"] )
	    end
	    calc.set_preference(:currency,'USD' )	    

	    #Spree::Preference.create(:key => "#{calc_type.underscore}/#{old_preference.first["attribute"]}/#{calc.id}", :value => old_preference.first["value"], :value_type => "decimal") if old_preference.first

          end

	  end
	  end
	  end