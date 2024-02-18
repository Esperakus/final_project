variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "cloud_id" {
  type = string
  default = ""
}

variable "folder_id" {
  type = string
  default = ""
}

variable "image_id" {
  type = string

  default = "fd8jgp0eknedm0jorvp7" # alma 8
}

variable "yc_token" {
  type    = string
  default = ""
}
