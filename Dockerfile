FROM continuumio/miniconda3

ENV LANG C.UTF-8

RUN apt-get update
RUN apt-get -y install gcc

RUN conda update -yq conda
RUN conda install -c msarahan libgcc
RUN apt-get install g++ -yq 

COPY ./requirements.txt /requirements.txt

RUN pip install --no-cache-dir -r requirements.txt \
    && python -m nltk.downloader 'punkt' \
    && python -m spacy download en

RUN rm -rf requirements.txt
RUN cd /
RUN mkdir server
COPY ./ServerLines /server
WORKDIR /server


RUN apt-get update && apt-get -y install openssh-server supervisor
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 5000 22
ENV DB_URL=https://graphql-on-pg.herokuapp.com/v1alpha1/graphql
CMD ["/usr/bin/supervisord"]



# CMD ["bash"]
# CMD ["python /server/YetAnotherFlaskServer.py"]
# CMD ["/bin/bash"]
# docker build -t swift3-ssh .  
# docker run -p 2222:22 -i -t swift3-ssh
# docker ps # find container id
# docker exec -i -t <containerid> /bin/bash