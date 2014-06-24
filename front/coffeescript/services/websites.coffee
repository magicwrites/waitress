window.application.service 'websites', () ->
    
    model = []
        
    # mock    
    
    model.push { name: 'magicwrites/partofuniverse', public: '1.12.0', latest: '1.24.5' }
    model.push { name: 'magicwrites/personal-website', public: '0.1.0', latest: '0.21.1' }
    
    exposed =
        model: model