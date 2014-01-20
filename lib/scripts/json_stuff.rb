puts Employee.all.as_json({
        include: [
          {manager: {only: [:first_name, :last_name, :email]}}
        ], only: [:id, :first_name, :last_name, :office_phone, :cell_phone, :status, :department, :manager_id, :email, :im_name, :im_client]
      }).map {|e| e.merge("im_client_url"=>e['im_client'])}.to_json
