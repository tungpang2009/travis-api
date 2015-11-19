module Travis::API::V3
  class Queries::Repository < Query
    params :id, :slug

    def find
      return by_slug if slug
      return Models::Repository.find_by_id(id) if id
      raise WrongParams, 'missing repository.id'.freeze
    end

    def star(repository, current_user)
      starred = Models::StarredRepository.where(repository_id: repository.id, user_id: current_user.id).first
      raise AlreadyStarred unless starred == nil
      Models::StarredRepository.create(repository_id: repository.id, user_id: current_user.id)
      repository
    end

    def unstar(repository, current_user)
      starred = Models::StarredRepository.where(repository_id: repository.id, user_id: current_user.id).first
      raise NotStarred if starred == nil
      starred.delete
      repository
    end

    private

    def by_slug
      owner_name, name = slug.split('/')
      Models::Repository.where(owner_name: owner_name, name: name, invalidated_at: nil).first
    end
  end
end
