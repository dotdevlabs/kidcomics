import { Controller } from "@hotwired/stimulus"
import {
  createIcons,
  Search,
  MapPin,
  Users,
  Calendar,
  Star,
  ChevronDown,
  User,
  Menu,
  X
} from "lucide"

export default class extends Controller {
  connect() {
    createIcons({
      icons: {
        Search,
        MapPin,
        Users,
        Calendar,
        Star,
        ChevronDown,
        User,
        Menu,
        X
      }
    })
  }
}
