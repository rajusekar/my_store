Deface::Override.new(:virtual_path => "spree/admin/shared/_tabs",
                     :name => "adding_link_adzones",
                     :insert_before => "code[erb-silent]:contains('if can? :admin, Spree::Promotion')")do
		     "<%= tab(:Adzones, :url => spree.admin_promotions_path, :icon => 'icon-bullhorn') %>"
		     end
