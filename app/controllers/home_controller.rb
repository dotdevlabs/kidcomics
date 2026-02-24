class HomeController < ApplicationController
  def index
    @clubs = fake_clubs
  end

  private

  def fake_clubs
    [
      {
        name: "Manchester United FC",
        image: "https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=400&h=300&fit=crop",
        rating: 5.0,
        location: "Manchester, UK",
        division: "Premier League",
        members: "750+ members",
        founded: "Est. 1878",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Barcelona FC",
        image: "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&h=300&fit=crop",
        rating: 5.0,
        location: "Barcelona, Spain",
        division: "La Liga",
        members: "800+ members",
        founded: "Est. 1899",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Bayern Munich",
        image: "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=300&fit=crop",
        rating: 5.0,
        location: "Munich, Germany",
        division: "Bundesliga",
        members: "650+ members",
        founded: "Est. 1900",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Juventus FC",
        image: "https://images.unsplash.com/photo-1551958219-acbc608c6377?w=400&h=300&fit=crop",
        rating: 4.9,
        location: "Turin, Italy",
        division: "Serie A",
        members: "600+ members",
        founded: "Est. 1897",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Arsenal FC",
        image: "https://images.unsplash.com/photo-1516478379841-22f1a0e024ad?w=400&h=300&fit=crop",
        rating: 4.9,
        location: "London, UK",
        division: "Premier League",
        members: "700+ members",
        founded: "Est. 1886",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Chelsea FC",
        image: "https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=400&h=300&fit=crop",
        rating: 4.8,
        location: "London, UK",
        division: "Premier League",
        members: "680+ members",
        founded: "Est. 1905",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Paris Saint-Germain",
        image: "https://images.unsplash.com/photo-1577223625816-7546f36a3178?w=400&h=300&fit=crop",
        rating: 5.0,
        location: "Paris, France",
        division: "Ligue 1",
        members: "720+ members",
        founded: "Est. 1970",
        tags: [ "Professional", "Men's" ]
      },
      {
        name: "Liverpool FC",
        image: "https://images.unsplash.com/photo-1522778119026-d627f1c94fa5?w=400&h=300&fit=crop",
        rating: 4.9,
        location: "Liverpool, UK",
        division: "Premier League",
        members: "750+ members",
        founded: "Est. 1892",
        tags: [ "Professional", "Men's" ]
      }
    ]
  end
end
