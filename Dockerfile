FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y libgdiplus
RUN apt-get install -y libvips
RUN apt-get install -y libc6-dev
#RUN apt-get install -y libx11-dev
#RUN apt-get install -y wget

#RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb

#RUN dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb || true && apt-get install -f -y



WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["QMS/QMS.csproj", "QMS/"]

RUN dotnet restore "QMS/QMS.csproj"
COPY . .

WORKDIR "/src/QMS"
RUN dotnet build "QMS.csproj" -c Release -o /app/build


FROM build AS publish
RUN dotnet publish "QMS.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app

copy ./QMS/wkhtmltox ./wkhtmltox
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QMS.dll"]
