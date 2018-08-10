FROM kriterion-base

ENV mongo_database kriterion
ENV mongo_hostname mongodb
ENV mongo_port 27017
ENV queue reports
ENV uri http://restmq:8888

ENTRYPOINT ["bundle", "exec", "kriterion", "worker"]
# CMD ["--debug"]
