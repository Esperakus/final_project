[haproxy_hosts]
%{ for hostname in web-lb_hosts ~}
${hostname}
%{ endfor ~}

[backend_hosts]
%{ for hostname in backend_hosts ~}
${hostname}
%{ endfor ~}

[db_hosts]
%{ for hostname in db_hosts ~}
${hostname}
%{ endfor ~}

[grafana]
%{ for hostname in grafana ~}
${hostname}
%{ endfor ~}

