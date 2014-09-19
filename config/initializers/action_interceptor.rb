ActionInterceptor.configure do

  interceptor :fine_print do
    account = current_account

    return if account && !account.is_anonymous?

    respond_to do |format|
      format.html { redirect_to openstax_accounts.login_url }
      format.json { head(:forbidden) }
    end
  end

end
