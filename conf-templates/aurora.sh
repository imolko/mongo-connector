#!/bin/bash

set -e

curl -XPUT "imk-elastic5:9200/avatares_${INDEX_NAME_SUFFIX}?pretty" -H 'Content-Type: application/json' -d'
{
    "settings": {
        "analysis": {
            "filter": {
                "imk_autocomplete_filter": { 
                    "type":     "edge_ngram",
                    "min_gram": 1,
                    "max_gram": 20
                }
            },
            "analyzer": {
                "imk_autocomplete":{
                    "type":      "custom",
                    "tokenizer": "uax_url_email",
                    "filter": [
                        "lowercase",
                        "imk_autocomplete_filter" 
                    ]        
                }
            }
        }
    },

    "mappings": {
        "master": {
            "dynamic": false,
            "properties": {
                "creado" : {
                    "type" : "date"
                },
                "modificado" : {
                    "type" : "date"
                },
                "lastSignalDate" : {
                    "type" : "date"
                },          
                "propietario" : {
                    "type" : "keyword",
                    "ignore_above" : 256
                },

                "perfil" : {
                    "properties" : {
                        "firstName" : {
                            "type" : "text",
                            "analyzer":"imk_autocomplete",
                            "search_analyzer": "standard"                
                        },
                        "surname" : {
                            "type" : "text",
                            "analyzer":"imk_autocomplete",
                            "search_analyzer": "standard"                
                        },
                        "empresa" : {
                            "type" : "text",
                            "analyzer":"imk_autocomplete",
                            "search_analyzer": "standard" 
                        },
                        "customId" : {
                            "type" : "keyword",
                            "ignore_above" : 256
                        },
                        "address" : {
                            "type" : "text"
                        },
                        "birthday" : {
                            "type" : "date"
                        },
                        "city" : {
                            "type" : "text"
                        },
                        "country" : {
                            "type" : "keyword",
                            "ignore_above": 50
                        },
                        "genre" : {
                            "type" : "keyword",
                            "ignore_above" : 50
                        },
                        "nick" : {
                            "type" : "text"
                        },
                        "position" : {
                            "type" : "text"
                        },
                        "skype" : {
                            "type" : "text"
                        },
                        "title" : {
                            "type" : "text"
                        }
                    }
                },

                "emails" : {
                    "properties" : {              
                        "buzon" : {
                            "type" : "text",
                            "analyzer":"imk_autocomplete",
                            "search_analyzer": "standard"
                        }
                    }
                },

                "phones" : { 
                    "properties" : {
                        "buzon" : {
                            "type" : "text",
                            "analyzer":"imk_autocomplete",
                            "search_analyzer": "standard"
                        }
                    }
                },

                "etiquetas" : {
                    "type" : "keyword",
                    "ignore_above" : 256            
                }          
            }
        }
    }
}

'

curl -XPOST "imk-elastic5:9200/_aliases?pretty" -H 'Content-Type: application/json' -d"
{
    \"actions\": [
        { \"add\": { \"index\": \"avatares_${INDEX_NAME_SUFFIX}\", \"alias\": \"avatares\" }}
    ]
}
"
