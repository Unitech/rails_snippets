#
# Mass Import with https://github.com/zdennis/activerecord-import
# SearchLogic
# find_in_batch method => mass object getting
# conditions handling
# exception handling
#


  def create
    #
    # decommenter require test_helper dans test de gift
    # + demander pour decommenter teardown dans les test
    #

    generic_users_array = params[:gift][:users_list].split("\r\n")
   
    if generic_users_array.empty?
      flash[:error] = 'Champs user vide'
      redirect_to :action => 'new'
      return 
    end
    
    # Remove useless space
    generic_users_array.each { |u| u.strip! }

    @gift_imported = nil
    gift_before_count = Gift.count

    # Switch conditions according to the type of user types 
    # defined by user_content_type
    conditions = []
    case params[:gift][:user_content_type]
    when 'emails'
      conditions = ['email IN (?)']
    when 'usernames'
      conditions = ['pseudo IN (?)']
    when 'ids'
      conditions = ['id IN (?)']
    else
      flash[:error] = 'We cant know what is sent as the user list (user_content_type field missing)'
      redirect_to :action => :new
      return
    end
    
    # Inject the last field for completing the condition
    conditions << generic_users_array;

    begin

      Gift.transaction do
        # Queries in groups of 300 to avoid big memory consumption
        User.find_in_batches(:conditions => conditions, 
                             :batch_size => 300) do |group|
          gifts_group = []
          group.each do |u|
            gifts_group << Gift.new(:amount => params[:gift][:amount].to_i,
                                    :comment => params[:gift][:comment],
                                    :user_id => u.id)
          end
          # Save all objects instancied
          @gift_imported = Gift.import [ :amount, :comment, :user_id ], gifts_group
        end
        
        # Check if enough objects was created comparing to actual Gift count
        if gift_before_count + generic_users_array.length != Gift.count
          # if not throw exception to rollback the entire transaction
          # The ActiveRecord::Rollback does not propage
          raise ActiveRecord::StatementInvalid
        end
      end
    rescue
      flash[:error] = 'There are errors on this form'
      redirect_to :action => :new
      return 
    end

    redirect_to :action => :index
    
  end
end
